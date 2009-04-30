/* --------------------------------------------------------------------------
 * Asteroid ruby extension.
 *   by Genki Takiuchi <takiuchi@drecom.co.jp>
 * -------------------------------------------------------------------------- */
#include <ruby.h>
#include <rubysig.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include "extconf.h"
#include "asteroid.h"

/* -------------------------------------------------------------------------- 
 * epoll / kqueue
 * - 2007/03/09 *BSD kqueue port, Mac OS X MSG_NOSIGNAL missing.
 *   (Takanori Ishikawa)
 * -------------------------------------------------------------------------- */
#ifdef HAVE_SYS_EVENT_H
#include <sys/event.h>
typedef int asteroid_pollfd_t;
typedef struct kevent asteroid_poll_event_t;
#endif

#ifdef HAVE_SYS_EPOLL_H
#include <sys/epoll.h>
typedef int asteroid_pollfd_t;
typedef struct epoll_event asteroid_poll_event_t;
#endif

static asteroid_pollfd_t asteroid_poll_create(int sizeHint) {
#ifdef HAVE_SYS_EVENT_H
  return kqueue();
#endif
#ifdef HAVE_SYS_EPOLL_H
  return epoll_create(sizeHint);
#endif
}

static int asteroid_poll_add(
  asteroid_pollfd_t pollfd,
  asteroid_poll_event_t *event,
  int fd) {
#ifdef HAVE_SYS_EVENT_H
  EV_SET(event, fd, EVFILT_READ, EV_ADD, 0, 0, NULL);
  return kevent(pollfd, event, 1, NULL, 0, NULL);
#endif
#ifdef HAVE_SYS_EPOLL_H
  event->events = (EPOLLIN | EPOLLPRI);
  event->data.fd = fd;
  return epoll_ctl(pollfd, EPOLL_CTL_ADD, fd, event);
#endif
}

static int asteroid_poll_remove(
  asteroid_pollfd_t pollfd,
  asteroid_poll_event_t *event,
  int fd) {
#ifdef HAVE_SYS_EVENT_H
  EV_SET(event, fd, EVFILT_READ, EV_DELETE, 0, 0, NULL);
  return kevent(pollfd, event, 1, NULL, 0, NULL);
#endif
#ifdef HAVE_SYS_EPOLL_H
  return epoll_ctl(pollfd, EPOLL_CTL_DEL, fd, event);
#endif
}

static int asteroid_poll_wait(
  asteroid_pollfd_t pollfd,
  asteroid_poll_event_t *events,
  int maxevents,
  int timeout) {
#ifdef HAVE_SYS_EVENT_H
  struct timespec tv, *tvptr;
  if (timeout < 0) {
    tvptr = NULL;
  }
  else {
    tv.tv_sec = (long) (timeout/1000);
    tv.tv_nsec = (long) (timeout%1000)*1000;
    tvptr = &tv;
  }
  return kevent(pollfd, NULL, 0, events, maxevents, tvptr);
#endif
#ifdef HAVE_SYS_EPOLL_H
  return epoll_wait(pollfd, events, maxevents, timeout);
#endif
}

#ifdef HAVE_SYS_EVENT_H
  #define AST_POLL_EVENT_SOCK(event) ((event)->ident)
  #define AST_POLL_EVENT_CAN_READ(event) ((event)->filter == EVFILT_READ)
#endif
#ifdef HAVE_SYS_EPOLL_H
  #define AST_POLL_EVENT_SOCK(event) ((event)->data.fd)
  #define AST_POLL_EVENT_CAN_READ(event) ((event)->events & (EPOLLIN|EPOLLPRI))
#endif

#ifdef SO_NOSIGPIPE
#ifndef MSG_NOSIGNAL
#define MSG_NOSIGNAL 0
#endif

/*
 * The preferred method on Mac OS X (10.2 and later) to prevent SIGPIPEs when
 * sending data to a dead peer (instead of relying on the 4th argument to send
 * being MSG_NOSIGNAL). Possibly also existing and in use on other BSD
 * systems? 
 *
 * curl-7.15.5/lib/connect.c 
 */

static void nosigpipe(int sockfd) {
  int one = 1;
  setsockopt(sockfd, SOL_SOCKET, SO_NOSIGPIPE, (void *)&one, sizeof(one));
}
#else
#define nosigpipe(x)
#endif

#define MAX_CONNECTION  (102400)
#define EVENT_BUF_SIZE  (1024)

static VALUE Asteroid;
static VALUE clients;
static volatile int running = 0;
static asteroid_pollfd_t epoll_fd = 0;
static asteroid_poll_event_t events[EVENT_BUF_SIZE];

int dispatch();
void runtime_error();

void Init_asteroid(){
  Asteroid = rb_define_module("Asteroid");
  rb_define_singleton_method(Asteroid, "run", asteroid_s_run, 3);
  rb_define_singleton_method(Asteroid, "stop", asteroid_s_stop, 0);
  rb_define_singleton_method(Asteroid, "now", asteroid_s_now, 0);
  rb_define_class_variable(Asteroid, "@@clients", clients = rb_hash_new());
}

static VALUE close_socket_proc(VALUE Pair, VALUE Arg, VALUE Self) {
  close(FIX2INT(RARRAY(Pair)->ptr[0]));
  return Qnil;
}

static VALUE asteroid_s_run(VALUE Self, VALUE Host, VALUE Port, VALUE Module){
  char *host = StringValuePtr(Host);
  int port = FIX2INT(Port);
  
  epoll_fd = asteroid_poll_create(1024);
  if(epoll_fd == -1) runtime_error();

  struct sockaddr_in addr;
  addr.sin_family = AF_INET;
  addr.sin_port = htons(port);
  addr.sin_addr.s_addr = inet_addr(host);
  int s = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP), c, one = 1;
  if(s == -1) runtime_error();
  fcntl(s, F_SETFL, fcntl(s, F_GETFL, 0) | O_NONBLOCK);
  setsockopt(s, SOL_SOCKET, SO_REUSEADDR, &one, sizeof(one));
  nosigpipe(s);
  if(bind(s, (struct sockaddr*)&addr, sizeof(addr)) != 0) runtime_error();
  if(listen(s, MAX_CONNECTION) != 0) runtime_error();
  if(rb_block_given_p()) rb_yield(Qnil);
  
  VALUE Class = rb_define_class_under(Asteroid, "Server", rb_cObject);
  rb_define_method(Class, "send_data",
    asteroid_server_send_data, 1);
  rb_define_method(Class, "write_and_close",
    asteroid_server_write_and_close, 0);
  rb_include_module(Class, Module);
  // Mac OS X, Fedora needs explicit rb_thread_schedule call.
  for(running = 1; running; rb_thread_schedule()){
    socklen_t len = sizeof(addr);
    while((c = accept(s, (struct sockaddr*)&addr, &len)) != -1){
      printf("A New client connected here\n");
      fcntl(c, F_SETFL, fcntl(c, F_GETFL, 0) | O_NONBLOCK);
      asteroid_poll_event_t event;
      memset(&event, 0, sizeof(event));
      if(asteroid_poll_add(epoll_fd, &event, c) == -1) runtime_error();
      // instantiate server class which responds to client.
      VALUE Server = rb_class_new_instance(0, NULL, Class);
      rb_iv_set(Server, "@fd", rb_fix_new(c));
      rb_hash_aset(clients, rb_fix_new(c), Server);
      if(rb_respond_to(Server, rb_intern("post_init"))){
        rb_funcall(Server, rb_intern("post_init"), 0);
      }
    }
    if(dispatch() != 0) asteroid_s_stop(Asteroid);
    // You must call them to give a chance for ruby to handle system events.
    // CHECK_INTS;
  }

  rb_iterate(rb_each, clients, close_socket_proc, Qnil);
  rb_funcall(clients, rb_intern("clear"), 0);
  close(s);
  close(epoll_fd);
  return Qnil;
}

static VALUE asteroid_s_stop(VALUE Self){
  running = 0;
  return Qnil;
}

static VALUE asteroid_s_now(VALUE Self){
  struct timeval now;
  gettimeofday(&now, NULL);
  return rb_float_new(now.tv_sec + now.tv_usec/1000000.0);
}

static VALUE asteroid_server_send_data(VALUE Self, VALUE Data){
  VALUE Fd = rb_iv_get(Self, "@fd");
  int fd = FIX2INT(Fd), remain = RSTRING(Data)->as.heap.len, len, trial = 100;
  char *data = StringValuePtr(Data);
  while(remain){
    len = send(fd, data, remain, MSG_DONTWAIT|MSG_NOSIGNAL);
    if(len == -1){
      if(errno == EAGAIN && --trial){
        rb_thread_schedule();
        // CHECK_INTS;
      }else{
        if(rb_respond_to(Self, rb_intern("unbind"))){
          rb_funcall(Self, rb_intern("unbind"), 0);
        }
        return Qnil;
      }
    }else{
      remain -= len;
      data += len;
    }
  }
  return Qtrue;
}

static VALUE asteroid_server_write_and_close(VALUE Self){
  VALUE Fd = rb_iv_get(Self, "@fd");
  int fd = FIX2INT(Fd);
  char buf[1];
  if(read(fd, buf, 1) == -1 && errno != EAGAIN){
    if(rb_respond_to(Self, rb_intern("unbind"))){
      rb_funcall(Self, rb_intern("unbind"), 0);
    }
  }
  asteroid_poll_event_t event;
  memset(&event, 0, sizeof(event));
  asteroid_poll_remove(epoll_fd, &event, fd);
  close(fd);
  rb_hash_delete(clients, Fd);
  return Qnil;
}

int dispatch(){
  int i, s, len;
  while(1){
    TRAP_BEG;
    s = asteroid_poll_wait(epoll_fd, events, EVENT_BUF_SIZE, 1);
    TRAP_END;
    if(s <= 0) break;
    for(i = 0; i < s; ++i){
      asteroid_poll_event_t event = events[i];
      int fd = AST_POLL_EVENT_SOCK(&event);
      VALUE Fd = rb_fix_new(fd);
      VALUE Server = rb_hash_aref(clients, Fd);
      if(AST_POLL_EVENT_CAN_READ(&event)){
        VALUE Buf = rb_str_new("", 0);
        char buf[1024];
        while((len = read(fd, buf, 1023)) > 0){
          buf[len] = '\0';
          rb_str_concat(Buf, rb_str_new2(buf));
        }
        if(len == -1 && errno == EAGAIN){
          if(rb_respond_to(Server, rb_intern("receive_data"))){
            rb_funcall(Server, rb_intern("receive_data"), 1, Buf);
          }
        }else{
          if(rb_respond_to(Server, rb_intern("unbind"))){
            rb_funcall(Server, rb_intern("unbind"), 0);
          }
          asteroid_poll_remove(epoll_fd, &event, fd);
          rb_hash_delete(clients, Fd);
          close(fd);
        }
      }
    }
  }
  return 0;
}

void runtime_error(){
  rb_raise(rb_eRuntimeError, strerror(errno));
}
