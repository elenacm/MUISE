#include <assert.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/select.h>
#include <sys/time.h>
#include <time.h>
#include <signal.h>
#include "fsm.h"
#include <stdbool.h>

#define RAISE_TIME	1000
#define LOWER_TIME	1000
#define NOP_TIME	1000
#define TIME_3  3000

enum posicion_barrera {
  TOP,
  MIDDLE,
  BOTTOM,
};

enum estado_temp{
  UNO,
  DOS,
};

//Temporizador
static int timer = 0;
static void timer_isr (union sigval arg) { timer = 1; }
static void timer_start (int ms){
  timer_t timerid;
  struct itimerspec spec;
  struct sigevent se;
  se.sigev_notify = SIGEV_THREAD;
  se.sigev_value.sival_ptr = &timerid;
  se.sigev_notify_function = timer_isr;
  se.sigev_notify_attributes = NULL;
  spec.it_value.tv_sec = ms / 1000;
  spec.it_value.tv_nsec = (ms % 1000) * 1000000;
  spec.it_interval.tv_sec = 0;
  spec.it_interval.tv_nsec = 0;
  timer_create (CLOCK_REALTIME, &se, &timerid);
  timer_settime (timerid, 0, &spec, NULL);
}

static int car_a_gate = 0;
static int gate_position = 0;
static int listo = 0;
static int car_just_exited = 0;

static int timer_finished (fsm_t* this) {
  return timer;
}

static int CocheEsperando (fsm_t* this) {
  if(car_a_gate == 1 && gate_position == 0) return 1;
  else return 0;
}

static int No_CocheEsperando (fsm_t* this) {
  if(car_a_gate == 0 && gate_position == 0) return 1;
  else return 0;
}

static int CocheFuera (fsm_t* this) { 
  if(car_just_exited == 1) return 1;
  else return 0;
}

static int SigoSubiendoATop (fsm_t* this){
  if(gate_position == 2) return 1;
  else return 0;
}

static int SubiendoMid (fsm_t* this){
  if(gate_position == 1 && car_a_gate == 1) return 1;
  else return 0;
}

static int BajandoMid (fsm_t* this){
  if(gate_position == 1 && car_a_gate == 0) return 1;
  else return 0;
}

static int BajoBarrera (fsm_t* this){  
  if(listo == 1) return 1;
  else return 0;
}

static int BajoBarreraABot (fsm_t* this){
  if(listo == 1) return 1;
  else return 0;
}

static int BarreraParadaArriba (fsm_t* this){
  if(gate_position == 2 && listo == 0) return 1;
  else return 0;
}
  
static void raise_up (fsm_t* this){printf("Subiendo barrera...\n");}
static void lower (fsm_t* this){printf("Bajando barrera...\n");}
static void nop (fsm_t* this){printf("Barrera parada\n");}
static void finish (fsm_t* this){printf("Barrera bajada\n");}

static void contador (fsm_t* this){
  listo = 0;
  timer = 0;
  printf("El coche ha pasado, esperando para bajar barrera\n");
  timer_start(TIME_3);
}

static void Terminado(fsm_t* this){
  listo = 1;
  car_just_exited = 0;
  printf("Bajando barrera...\n");
}

// Explicit FSM description
static fsm_trans_t barrera[] = {

  { BOTTOM, CocheEsperando, MIDDLE, raise_up},
  { BOTTOM, No_CocheEsperando, BOTTOM, nop},
  { MIDDLE, SigoSubiendoATop, TOP, nop },
  { MIDDLE, SubiendoMid, MIDDLE, raise_up},  
  { MIDDLE, BajoBarreraABot, BOTTOM, finish},
  { MIDDLE, BajandoMid, MIDDLE, lower },  
  { TOP, BajoBarrera, MIDDLE, lower },
  { TOP, BarreraParadaArriba, TOP, nop },  
  {-1, NULL, -1, NULL},

};

static fsm_trans_t temporizador[] = {

  { UNO, CocheFuera, DOS, contador},
  { DOS, timer_finished, UNO, Terminado},
  {-1, NULL, -1, NULL },

};

// res = a - b

void timeval_sub (struct timeval *res, struct timeval *a, struct timeval *b){
  res->tv_sec = a->tv_sec - b->tv_sec;
  res->tv_usec = a->tv_usec - b->tv_usec;
  if (res->tv_usec < 0) {
    --res->tv_sec;
    res->tv_usec += 1000000;
  }
}

// res = a + b

void timeval_add (struct timeval *res, struct timeval *a, struct timeval *b){
  res->tv_sec = a->tv_sec + b->tv_sec
    + a->tv_usec / 1000000 + b->tv_usec / 1000000; 
  res->tv_usec = a->tv_usec % 1000000 + b->tv_usec % 1000000;
}

// wait until next_activation (absolute time)
void delay_until (struct timeval* next_activation){
  struct timeval now, timeout;
  gettimeofday (&now, NULL);
  timeval_sub (&timeout, next_activation, &now);
  select (0, NULL, NULL, NULL, &timeout);
}

int main (){
  struct timeval clk_period = { 0, 250 * 1000 };
  struct timeval next_activation;

  fsm_t* barrera_fsm = fsm_new (barrera);
  fsm_t* temp_fsm = fsm_new (temporizador);

  gettimeofday (&next_activation, NULL);
  
  while (scanf("%d %d %d", &car_a_gate, &gate_position, &car_just_exited) == 3) {       
      fsm_fire (barrera_fsm);
      fsm_fire (temp_fsm);

      gettimeofday (&next_activation, NULL);
      timeval_add (&next_activation, &next_activation, &clk_period);
      delay_until (&next_activation);         
  }

  return 1;
}
