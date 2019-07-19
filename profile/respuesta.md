# Sección Profiling

## Comando time

Se compilaron ambos codigos de forma tradicional con cuatro niveles de optimizaciones

~~~~
gcc -O profile_me_1.c  -o profile_me_1_opt0.e
gcc -O1 profile_me_1.c  -o profile_me_1_opt1.e
gcc -O2 profile_me_1.c  -o profile_me_1_opt2.e
gcc -O3 profile_me_1.c  -o profile_me_1_opt3.e
~~~~

~~~~
gcc -lm -O profile_me_2.c  -o profile_me_2_opt0.e
gcc -lm -O1 profile_me_2.c  -o profile_me_2_opt1.e
gcc -lm -O2 profile_me_2.c  -o profile_me_2_opt2.e
gcc -lm -O3 profile_me_2.c  -o profile_me_2_opt3.e
~~~~

### profile_me_1.c

Este código se corrigio porque daba SIGFAULT, para solucionar declare a los array como globales.
Cuando se corrió el comando time se obtuvieron los siguientes tiempos:

~~~~
[shell]$ time ./profile_me_1_opt0.e

real	0m1.177s
user	0m0.960s
sys	0m0.213s
~~~~

~~~~
[shell]$ time ./profile_me_1_opt1.e

real	0m1.145s
user	0m0.951s
sys	0m0.190s
~~~~

~~~~
[shell]$ time ./profile_me_1_opt2.e

real	0m1.186s
user	0m0.949s
sys	0m0.230s
~~~~

~~~~
[shell]$ time ./profile_me_1_opt3.e

real	0m0.906s
user	0m0.674s
sys	0m0.229s
~~~~

No se ven cambios muy significativos entre los diferentes niveles de optimizaciones, quizas un valor menor en la optimizacion 3 pero supongo no significativo (para verificar deberia hacer un test estadistico o algo asi pero no tengo ganas.).

### profile_me_2.c

Este programa tiene argumento de entrada, se probaron dos casos:

**200**

~~~~
[shell]$ time ./profile_me_2_opt0.e 200
1007.04
real	0m0.002s
user	0m0.000s
sys	0m0.002s
~~~~

~~~~
[shell]$ time ./profile_me_2_opt1.e 200
1007.04
real	0m0.004s
user	0m0.000s
sys	0m0.004s
~~~~

~~~~
[shell]$ time ./profile_me_2_opt2.e 200
1007.04
real	0m0.005s
user	0m0.000s
sys	0m0.005s
~~~~

~~~~
[shell]$ time ./profile_me_2_opt3.e 200
1007.04
real	0m0.005s
user	0m0.001s
sys	0m0.004s
~~~~

Los tiempos fueron demasiados chicos, además que no hay diferencia entre niveles de optimización.

**90000000**

~~~~
[shell]$ time ./profile_me_2_opt0.e 90000000
-nan
real	0m2.715s
user	0m1.995s
sys	0m0.712s
~~~~

~~~~
[shell]$ time ./profile_me_2_opt1.e 90000000
-nan
real	0m2.602s
user	0m1.870s
sys	0m0.725s
~~~~

~~~~
[shell]$ time ./profile_me_2_opt2.e 90000000
-nan
real	0m2.581s
user	0m1.911s
sys	0m0.662s
~~~~

~~~~
[shell]$ time ./profile_me_2_opt3.e 90000000
-nan
real	0m2.611s
user	0m1.939s
sys	0m0.666s
~~~~

Tampoco hay diferencias significativas. La salida se rompen porque la función exponencial crece sin cota, y llega a Inf, y ese error se propaga.

## Comando gperf
Para poder usar este software se necesita compilar el codigo con el flag `-pg`:

~~~~
gcc -O -pg profile_me_1.c  -o profile_me_1_opt0_gperf.e
gcc -O3 -pg profile_me_1.c  -o profile_me_1_opt3_gperf.e
~~~~

~~~~
gcc -lm -O -pg profile_me_2.c  -o profile_me_2_opt0_gperf.e
gcc -lm -O3 -pg profile_me_2.c  -o profile_me_2_opt3_gperf.e
~~~~

### profile_me_1.c

~~~~
Flat profile:

Each sample counts as 0.01 seconds.
  %   cumulative   self              self     total           
 time   seconds   seconds    calls  ns/call  ns/call  name    
 56.87      0.56     0.56 25000000    22.29    22.29  first_assign
 36.71      0.92     0.36                             main
  6.20      0.98     0.06 25000000     2.43     2.43  second_assign
  1.03      0.99     0.01                             frame_dummy


			Call graph


granularity: each sample hit covers 2 byte(s) for 1.01% of 0.99 seconds

index % time    self  children    called     name
                                                 <spontaneous>
[1]     99.0    0.36    0.62                 main [1]
                0.56    0.00 25000000/25000000     first_assign [2]
                0.06    0.00 25000000/25000000     second_assign [3]
-----------------------------------------------
                0.56    0.00 25000000/25000000     main [1]
[2]     56.4    0.56    0.00 25000000         first_assign [2]
-----------------------------------------------
                0.06    0.00 25000000/25000000     main [1]
[3]      6.2    0.06    0.00 25000000         second_assign [3]
-----------------------------------------------
                                                 <spontaneous>
[4]      1.0    0.01    0.00                 frame_dummy [4]
-----------------------------------------------


Index by function name

   [2] first_assign            [1] main
   [4] frame_dummy             [3] second_assign
~~~~
