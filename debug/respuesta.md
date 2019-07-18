# Sección Bugs

## Primera compilación

Cuando compile por primera vez todo los programas tuve los siguientes casos.

### add_array_static_c*

Vi que la compilación de *add_array_static_c* me dio los siguientes warnings:

~~~~
gcc  -c add_array_static.c -o add_array_static_c.o
add_array_static.c: In function ‘add_array’:
add_array_static.c:7:12: warning: implicit declaration of function ‘abs’ [-Wimplicit-function-declaration]
    7 |     sum += abs(a[i]);
      |            ^~~
gcc  -c add_array_segfault.c -o add_array_segfault_c.o
add_array_segfault.c: In function ‘add_array’:
add_array_segfault.c:7:12: warning: implicit declaration of function ‘abs’ [-Wimplicit-function-declaration]
    7 |     sum += abs(a[i]);
      |            ^~~
gcc  -c add_array_nobugs.c -o add_array_nobugs_c.o
add_array_nobugs.c: In function ‘add_array’:
add_array_nobugs.c:7:12: warning: implicit declaration of function ‘abs’ [-Wimplicit-function-declaration]
    7 |     sum += abs(a[i]);
      |       
~~~~

No significa que tenga un error. Pero es algo que llama la atención y minimo tenerse en cuenta.

La linea origen del warning es:

~~~~c
sum += abs(a[i]);
~~~~

Es con respecto a la funcion abs. Por otro lado, cuando se ejecuta el programa, la salida es:

~~~~
The addition is -1965629661
~~~~

Analizando el codigo, la salida deberia ser 6. Claramente hay un bug. En mi primera hipotesis, creo que debido al warning que se refiere a la no declaracion de la funcion abs(). Busco en Google y encuentro esto:

[abs 'implicit declaration…' error after including math.h - stackoverflow](https://stackoverflow.com/questions/29577833/abs-implicit-declaration-error-after-including-math-h)

Incluyo la libreria estandar <stdlib.h> en el header y ahora si se compila sin warnigs. Vuelvo a ejecutar el programa y la salida es:

~~~~
The addition is -762452489
~~~~

O sea el bug no estaba asociado al warning, probablemente gcc se daba cuenta automaticamente y agregaba <stdlib.h> pero me daba un warning. Lo interesante es que cada vez que se ejecuta el programa, la salida es diferente. Eso me hace sospechar que esta accediendo a una parte de memoria que tenga *basura*. Como no me da segfault, debe ser cercana al programa o que el programa tiene permiso de acceso. Mi conocimiento en C me da a sospechar que está relacionado al acceso de los arrays, y que la variable usada como contador está accediendo por fuera del largo del array.

Viendo el codigo en *add_array_static.c*, noté que el ciclo **for** de la función *add_array()* es sospechoso.

~~~~c
for (i = 0; i <= n + 1; i++) {
  sum += abs(a[i]);
  sum += abs(b[i]);
};   
~~~~

*n* es un argumento de la función y tiene como valor tres. Los array a y b en creados en el main y que ingresan como argumento tienen un largo de 3, y recordemos que en C, el acceso a un array de 3 elementos se accede de 0 a 2. Pero en el ciclo for aparece **i <= n + 1**, es decir los valores que el ciclo for acepta son 0,1,2,3 y 4. O sea 3 y 4 no son valores permitidos de los arrays usados por consiguiente va a estar accediendo a memoria que no forman parte de los mismos. Por una cuestion de aprender a usar la herramienta *gdb* que se enseño en este Workshop voy a verificar como evoluciona la variable *i* del ciclo *for* para comprobar lo que digo, para ello compilo agregando el flag *--debug* en el MakeFile.

~~~~
(gdb) break 8
Breakpoint 1 at 0x116f: file add_array_static.c, line 8.
(gdb) run
Starting program: /home/facundo/Documents/WTPC/Dia4/HOdebug-profile/debug/bugs/add_array_static.e

Breakpoint 1, add_array (a=0x7fffffffdfd0, b=0x7fffffffdfdc, n=3)
    at add_array_static.c:8
8	    sum += abs(a[i]);
(gdb) print(i)
$1 = 0

(gdb) continue
Continuing.

Breakpoint 1, add_array (a=0x7fffffffdfd0, b=0x7fffffffdfdc, n=3)
    at add_array_static.c:8
8	    sum += abs(a[i]);
(gdb) print(i)
$3 = 1
(gdb) continue
Continuing.

Breakpoint 1, add_array (a=0x7fffffffdfd0, b=0x7fffffffdfdc, n=3)
    at add_array_static.c:8
8	    sum += abs(a[i]);
(gdb) print(i)
$4 = 2
(gdb) continue
Continuing.

Breakpoint 1, add_array (a=0x7fffffffdfd0, b=0x7fffffffdfdc, n=3)
    at add_array_static.c:8
8	    sum += abs(a[i]);
(gdb) print(i)
$5 = 3
(gdb) continue
Continuing.

Breakpoint 1, add_array (a=0x7fffffffdfd0, b=0x7fffffffdfdc, n=3)
    at add_array_static.c:8
8	    sum += abs(a[i]);
(gdb) print(i)
$6 = 4
(gdb) print a[i]
$7 = 1
(gdb) print b[i]
$8 = -863281480
~~~~

Vemos que en efecto el contador del ciclo for está accediendo a valores que están por fuera del array y que en efecto como se observa con *print b[i]* se está accediendo a memoria *basura*.

Se corrigió el error.

~~~~c
for (i = 0; i < n; i++) {
  sum += abs(a[i]);
  sum += abs(b[i]);
};   
~~~~

Se recompiló y la salida es:

~~~~
The addition is 6
~~~~
