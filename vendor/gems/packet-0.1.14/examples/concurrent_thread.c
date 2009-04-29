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

static VALUE ConcurrentThread;
static VALUE ConcurrentThreadPool;

static void count_to_10000(void* data){
  int i = 0;
  for( i = 0; i < 10000; i++ ) {
    if ((*(VALUE *)data) == Qtrue) break;
    printf("Currently Counting from thr 1: %d\n",i);
  }
}

static void count_to_20000(void* data){
  int i = 0;
  for( i = 0; i < 10000; i++ ) {
    if ((*(VALUE *)data) == Qtrue) break;
    printf("Currently Counting from thr 2: %d\n",i);
  }
}

static void stop_thr1(void* data) {
  printf("Calling thread1 break method\n");
  *((VALUE *)data) = Qtrue;
}

static void stop_thr2(void* data) {
  printf("Calling thread2 break method\n");
  *((VALUE *)data) = Qtrue;
}

static VALUE rb_concurrent_thread_method(VALUE self)
{
  VALUE interrupt_flag;
  VALUE interrupt_flag2;
  rb_thread_blocking_region(count_to_10000,&interrupt_flag,stop_thr1,&interrupt_flag);
  rb_thread_blocking_region(count_to_20000,&interrupt_flag2,stop_thr2,&interrupt_flag2);
}


void Init_concurrent_thread(){
  ConcurrentThread = rb_define_class("ConcurrentThread",rb_cObject);
  rb_define_method(ConcurrentThread,"defer",rb_concurrent_thread_method,0);
}
