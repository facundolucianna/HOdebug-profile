# Sección Profiling

## Comando time

Se compilaron ambos codigos de forma tradicional con cuatro niveles de optimizaciones

~~~~
gcc -O0 profile_me_1.c  -o profile_me_1_opt0.e
gcc -O1 profile_me_1.c  -o profile_me_1_opt1.e
gcc -O2 profile_me_1.c  -o profile_me_1_opt2.e
gcc -O3 profile_me_1.c  -o profile_me_1_opt3.e
~~~~

~~~~
gcc -lm -O0 profile_me_2.c  -o profile_me_2_opt0.e
gcc -lm -O1 profile_me_2.c  -o profile_me_2_opt1.e
gcc -lm -O2 profile_me_2.c  -o profile_me_2_opt2.e
gcc -lm -O3 profile_me_2.c  -o profile_me_2_opt3.e
~~~~

### profile_me_1.c

Cuando se corrió el comando time se obtuvieron los siguientes tiempos:

~~~~
[shell]$ time ./profile_me_1_opt0.e

real	0m1.874s
user	0m1.565s
sys	0m0.303s
~~~~

~~~~
[shell]$ time ./profile_me_1_opt1.e

real	0m1.895s
user	0m1.579s
sys	0m0.307s
~~~~

~~~~
[shell]$ time ./profile_me_1_opt2.e

real	0m0.003s
user	0m0.000s
sys	0m0.004s
~~~~

~~~~
[shell]$ time ./profile_me_1_opt3.e

real	0m0.003s
user	0m0.000s
sys	0m0.003s
~~~~

Entre la optimización 1 y 2 el cambio es notoriamente significativo, lo que antes demoraba 2 segundos, a partir de la optimizacion nivel 2, lo realiza de forma practicamente instantaneo.

### profile_me_2.c

Este programa tiene argumento de entrada, se probaron dos casos:

**200**

~~~~
[shell]$ time ./profile_me_2_opt0.e 200
1007.04
real	0m0.005s
user	0m0.004s
sys	0m0.001s
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
real	0m0.004s
user	0m0.001s
sys	0m0.004s
~~~~

~~~~
[shell]$ time ./profile_me_2_opt3.e 200
1007.04
real	0m0.004s
user	0m0.000s
sys	0m0.004s
~~~~

Los tiempos fueron demasiados chicos como para notar algun cambio.

**90000000**

~~~~
[shell]$ time ./profile_me_2_opt0.e 90000000
-nan
real	0m4.822s
user	0m3.808s
sys	0m1.004s
~~~~

~~~~
[shell]$ time ./profile_me_2_opt1.e 90000000
-nan
real	0m3.546s
user	0m2.449s
sys	0m1.087s
~~~~

~~~~
[shell]$ time ./profile_me_2_opt2.e 90000000
-nan
real	0m3.534s
user	0m2.532s
sys	0m0.990s
~~~~

~~~~
[shell]$ time ./profile_me_2_opt3.e 90000000
-nan
real	0m3.582s
user	0m2.511s
sys	0m1.063s
~~~~

El cambio grande ocurre entre la optimizacion 0 y 1, bajando aproximadamente un segundo. La salida se rompen porque la función exponencial crece sin cota, y llega a Inf, y ese error se propaga.

## Comando gperf
Para poder usar este software se necesita compilar el codigo con el flag `-pg`:

~~~~
gcc -Wall -pg -O0 -pg profile_me_1.c  -o profile_me_1_opt0_gperf.e
gcc -Wall -pg -O2 -pg profile_me_1.c  -o profile_me_1_opt3_gperf.e
~~~~

~~~~
gcc -Wall -pg -lm -O0 -pg profile_me_2.c  -o profile_me_2_opt0_gperf.e
gcc -Wall -pg -lm -O1 -pg profile_me_2.c  -o profile_me_2_opt3_gperf.e
~~~~

Y se generan los documentos del profiling haciendo:

~~~~
./profile_me_1_opt0_gperf.e
gprof profile_me_1_opt0_gperf.e gmon.out > profile_me_1_opt0_analysis.txt
./profile_me_1_opt3_gperf.e
gprof profile_me_1_opt3_gperf.e gmon.out > profile_me_1_opt3_analysis.txt
~~~~

~~~~
./profile_me_2_opt0_gperf.e 90000000
gprof profile_me_2_opt0_gperf.e gmon.out > profile_me_2_opt0_analysis.txt
./profile_me_2_opt3_gperf.e 90000000
gprof profile_me_2_opt3_gperf.e gmon.out > profile_me_2_opt1_analysis.txt
~~~~

### profile_me_1.c

**profile_me_1_opt0_analysis.txt**

~~~~
Flat profile:

Each sample counts as 0.01 seconds.
  %   cumulative   self              self     total           
 time   seconds   seconds    calls  ns/call  ns/call  name    
 63.04      0.78     0.78 25000000    31.27    31.27  first_assign
 30.10      1.15     0.37                             main
  7.73      1.25     0.10 25000000     3.83     3.83  second_assign


  Call graph (explanation follows)


granularity: each sample hit covers 2 byte(s) for 0.80% of 1.25 seconds

index % time    self  children    called     name
                                          <spontaneous>
[1]    100.0    0.37    0.88                 main [1]
         0.78    0.00 25000000/25000000     first_assign [2]
         0.10    0.00 25000000/25000000     second_assign [3]
-----------------------------------------------
         0.78    0.00 25000000/25000000     main [1]
[2]     62.5    0.78    0.00 25000000         first_assign [2]
-----------------------------------------------
         0.10    0.00 25000000/25000000     main [1]
[3]      7.7    0.10    0.00 25000000         second_assign [3]
-----------------------------------------------
~~~~

**profile_me_1_opt3_analysis.txt**

~~~~
Flat profile:

Each sample counts as 0.01 seconds.
 no time accumulated
~~~~

Se ve claramente que la optimizacion 3 elimina todo código. Observando el codigo se observa que no se hace nada con los arrays, se los operan pero no se muestran en pantalla o nada que pueda significar alguna utilidad, por lo que en este nivel de optimización, decide eliminar todo. Verifiquemos viendo el codigo en Assembler:

~~~~
[shell]$ cat profile_me_1_opt3.asm
...
main:
.LFB13:
	.cfi_startproc
	xorl	%eax, %eax
	ret
	.cfi_endproc
...
~~~~

Se ve que en el main hace un xorl que esta poniendo en cero un registro, analizando el main(), no es mas que el return 0, por lo que el codigo estar retornando 0 y termina, que confirma lo que se mencionó anteriormente.

### profile_me_2.c

**profile_me_2_opt0_analysis.txt**

~~~~
Flat profile:

Each sample counts as 0.01 seconds.
  %   cumulative   self              self     total           
 time   seconds   seconds    calls  Ts/call  Ts/call  name    
100.98      3.01     3.01                             main
~~~~

**profile_me_2_opt1_analysis.txt**

~~~~
Flat profile:

Each sample counts as 0.01 seconds.
  %   cumulative   self              self     total           
 time   seconds   seconds    calls  Ts/call  Ts/call  name    
 99.52      2.02     2.02                             main
~~~~

Se ve nuevamente la reducción de un segundo, pero como el programa no llama a funciones, no se puede obtener una información mas detallada que el comando `time`.

## Comando perf

Con el comando perf se va a analizar solamente a **profile_me_2**, ya que con `gperf` no se pudo obtener información relevante.

~~~~
perf record ./profile_me_2_opt0.e 90000000
perf report
~~~~

~~~~
perf record ./profile_me_2_opt1.e 90000000
perf report
~~~~

Viendo los reporte de perf en ambos casos, noto que con la optimización no está llamando a sqrt(). Lo reemplazo con una instrucción (`sqrtsd   %xmm3,%xmm3`), o sea paso de una implementación generica a una especifica de la ALU del microprocesador, ignoro como lo tiene implementado glibc, pero al menos se está ahorrando el salto a la libreria.

Si quisiera volver mas optimizado el código, se me ocurre en este caso, por un lado eliminar a los arrays `b` y `c` por valores contantes, ya que no cambian. Luego reducir los 4 for en uno solo, y si quisiera super-optimizar, buscar librerias para las funciones seno y exponencial y hacerlas estáticas.
