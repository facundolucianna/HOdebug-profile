# Sección Bugs

## Primera compilación

Cuando compile por primera vez todo los programas tuve los siguientes casos.

### add_array_static.c

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

*n* es un argumento de la función y tiene como valor tres. Los arrays a y b son creados en el main y que ingresan como argumento tienen un largo de 3, y recordemos que en C, el acceso a un array de 3 elementos se accede de 0 a 2. Pero en el ciclo for aparece **i <= n + 1**, es decir los valores que el ciclo for acepta son 0,1,2,3 y 4. O sea 3 y 4 no son valores permitidos de los arrays usados por consiguiente va a estar accediendo a memoria que no forman parte de los mismos. Por una cuestion de aprender a usar la herramienta *gdb* que se enseño en este Workshop voy a verificar como evoluciona la variable *i* del ciclo *for* para comprobar lo que digo, para ello compilo agregando el flag *--debug* en el MakeFile.

~~~~
(gdb) break 8
Breakpoint 1 at 0x116f: file add_array_static.c, line 8.
(gdb) run
Starting program: add_array_static.e

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

### add_array_segfault.c

Este codigo se compila y cuando se ejecuta da un error de SEGFAULT. Claramente está accediendo a memoria que no puede acceder. Mi deducción de haber trabajado en C me hace sospechar de punteros, siempre tengo problema de punteros y SEGFAULT. Voy a trabajar con el debugger para ver en detalle ademas voy a compilar con la opcion de que muestre todos los warnings.

La complación me aparece el siguiente warning nuevo:

~~~~
gcc -Wall --debug -c add_array_segfault.c -o add_array_segfault_c.o
add_array_segfault.c: In function ‘add_array’:
add_array_segfault.c:7:12: warning: implicit declaration of function ‘abs’ [-Wimplicit-function-declaration]
    7 |     sum += abs(a[i]);
      |            ^~~
add_array_segfault.c: In function ‘main’:
add_array_segfault.c:18:6: warning: ‘a’ may be used uninitialized in this function [-Wmaybe-uninitialized]
   18 |     a[i] = i;
      |      ^
add_array_segfault.c:19:6: warning: ‘b’ may be used uninitialized in this function [-Wmaybe-uninitialized]
   19 |     b[i] = i;
      |      ^
~~~~

Los dos ultimos warnings viendo en internet veo un comentario de stackoverflow sobre punteros mal declarados, sospechoso :thinking:

[Warning: X may be used uninitialized in this function - stackoverflow](https://stackoverflow.com/questions/12958931/warning-x-may-be-used-uninitialized-in-this-function)

Veamos gdb

~~~~
(gdb) run
Starting program: add_array_segfault.e

Program received signal SIGSEGV, Segmentation fault.
0x00005555555551fe in main (argc=1, argv=0x7fffffffe0d8)
    at add_array_segfault.c:19
19	    b[i] = i;
~~~~

Vemos que justamente hay una señal de SEGFAULT. Dentro de la función las variables en gdb nos da:

~~~~
(gdb) print(a[0])
$7 = 1
(gdb) print(a[1])
$8 = 0
(gdb) print(a[2])
$9 = -7065
(gdb) print(b[0])
Cannot access memory at address 0x0
(gdb) print(b[1])
Cannot access memory at address 0x4
(gdb) print(b[2])
Cannot access memory at address 0x8
~~~~

Ahi se ve el error de segementación. El array **a** esta diciendo cualquier cosa, por otro lado el array **b** no esta pudiendo a acceder a direcciones de memoria 0x0, 0x4 y 0x8, esas memorias me dan un dato vital. Si se supone que cada espacio de memoria ocupan 4 bytes, serian el espacio 0, 1 y 2 (no se si la arquitectura respeta lo de 4 bytes pero parece coincidir), es decir que se envió como puntero los resultados el contenido y no la direccion de memoria del array.

Con toda esta información uno va al codigo y observa que cuando se declaran dos punteros *a* y *b*:

~~~~c
int *a, *b;
~~~~

Y luego se los usa como arrays. Si se desea mantener que dichos punteros sean punteros, se debe modificar el codigo para dirigirlos en memoria a un array existente y luego acceder a dichos espacios del array usando la notacion en array:

~~~~c
int *a, *b;
int aArray[3];
int bArray[3];

a = aArray;
b = bArray;
~~~~

### add_array_dynamic.c

Este codigo se compila y cuando se ejecuta da como resultado cero. A difenencia de los otros codigos, se usa memoria dinamica con *malloc()*.

El resultado es cero:

~~~~
The addition is 0
~~~~

Viendo el codigo, se observa el mismo problema que en los otros programas,

~~~~c
sum = 1
for (i = 1; i <= n + 1; i++) {
  sum = sum * abs(a[i]);
  sum = sum * abs(b[i]);
};   
~~~~

Solo para verificar se va ir viendo en *gdb* que da como salida en cada loop la función:

~~~~
(gdb) step
7	  for (i = 1; i <= (n + 1) ; i++) {
(gdb) step
8	    sum = sum * abs(a[i]);
(gdb) step
9	    sum = sum * abs(b[i]);
(gdb) print i
$3 = 2
(gdb) print sum
$4 = 2
(gdb) step
7	  for (i = 1; i <= (n + 1) ; i++) {
(gdb) step
8	    sum = sum * abs(a[i]);
(gdb) step
9	    sum = sum * abs(b[i]);
(gdb) print i
$5 = 3
(gdb) print sum
$6 = 0
~~~~

En donde se ve en efecto el error. Cuando se sobrepasa la memoria, por algun motivo los espacios consiguientes hay ceros (probablemente el compilador los rellena de cero). Ajustando el ciclo *for* funciona como se espera.

~~~~c
for (i = 1; i < n ; i++) {
  sum = sum * abs(a[i]);
  sum = sum * abs(b[i]);
};
~~~~

La salida es:

~~~~
The addition is 4
~~~~

### add_array_nobugs.c

Se verifico el programa *add_array_nobugs.c* por si habia algo raro a pesar de su nombre, pero en efecto no se encotraron errores. 
