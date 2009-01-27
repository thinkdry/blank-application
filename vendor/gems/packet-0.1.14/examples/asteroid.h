static VALUE asteroid_s_run(VALUE Self, VALUE Host, VALUE Port, VALUE Module);
static VALUE asteroid_s_stop(VALUE Self);
static VALUE asteroid_s_now(VALUE Self);
static VALUE asteroid_server_send_data(VALUE Self, VALUE Data);
static VALUE asteroid_server_write_and_close(VALUE Self);
