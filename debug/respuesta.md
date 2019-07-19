# Sección Bugs

### add_array_static.c

Vi que la compilación de `add_array_static_c` me dio los siguientes warnings:

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

O sea el bug no estaba asociado al warning, probablemente está linkeado de forma dinamica. Lo interesante es que cada vez que se ejecuta el programa, la salida es diferente. Eso me hace sospechar que esta accediendo a una parte de memoria que tenga *basura*. Como no me da segfault, debe ser cercana al programa o que el programa tiene permiso de acceso. Mi conocimiento en C me da a sospechar que está relacionado al acceso de los arrays, y que la variable usada como contador está accediendo por fuera del largo del array.

Viendo el codigo en `add_array_static.c`, noté que el ciclo `for` de la función `add_array()` es sospechoso.

~~~~c
for (i = 0; i <= n + 1; i++) {
  sum += abs(a[i]);
  sum += abs(b[i]);
};   
~~~~

`n` es un argumento de la función y tiene como valor tres. Los arrays `a` y `b` son creados en el main y que ingresan como argumento tienen un largo de 3, y recordemos que en C, el acceso a un array de 3 elementos se accede de 0 a 2. Pero en el ciclo for aparece `i <= n + 1`, es decir los valores que el ciclo for acepta son 0,1,2,3 y 4. O sea 3 y 4 no son valores permitidos de los arrays usados por consiguiente va a estar accediendo a memoria que no forman parte de los mismos. Por una cuestion de aprender a usar la herramienta `gdb` que se enseño en este Workshop voy a verificar como evoluciona la variable `i` del ciclo `for` para comprobar lo que digo, para ello compilo agregando el flag `--debug` en el MakeFile.

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

Vemos que en efecto el contador del ciclo for está accediendo a valores que están por fuera del array y que en efecto como se observa con `print b[i]` se está accediendo a memoria *basura*.

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

Vemos que justamente hay una señal de SEGFAULT. Dentro de la función las variables en `gdb` nos da:

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

Ahi se ve el error de segementación. El array `a` esta diciendo cualquier cosa, por otro lado el array `b` no esta pudiendo a acceder a direcciones de memoria 0x0, 0x4 y 0x8, esas memorias me dan un dato vital. Si se supone que cada espacio de memoria ocupan 4 bytes, serian el espacio 0, 1 y 2 (no se si la arquitectura respeta lo de 4 bytes pero parece coincidir), es decir que se envió como puntero los resultados el contenido y no la direccion de memoria del array.

Con toda esta información uno va al codigo y observa que cuando se declaran dos punteros `a` y `b`:

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

Este codigo se compila y cuando se ejecuta da como resultado cero. A difenencia de los otros codigos, se usa memoria dinamica con `malloc()`.

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

Solo para verificar se va ir viendo en `gdb` que da como salida en cada loop la función:

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

En donde se ve en efecto el error. Cuando se sobrepasa la memoria, por algun motivo los espacios consiguientes hay ceros (probablemente el compilador los rellena de cero). Ajustando el ciclo `for` funciona como se espera.

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

Se verifico el programa `add_array_nobugs.c` por si habia algo raro a pesar de su nombre, pero en efecto no se encotraron errores.

# Floating point exception

### Pregunta 1

La función que requiere agregar `-DTRAPFPE` es `set_fpe_x87_sse()`.

Para poder compilar usando con el flag `-DTRAPFPE` y que linkee con el archivo objeto que tiene esa función, compilé con gcc de la siguiente forma:

~~~~
gcc -c fpe_x87_sse.c  -o fpe_x87_sse.o
gcc -DTRAPFPE -Ifpe_x87_sse -c comparison.c -o comparison_fpe.o
gcc -lm comparison_fpe.o ./fpe_x87_sse/fpe_x87_sse.o -o comparison_fpe.e
~~~~

### Pregunta 2

La diferencia entre usar el flag `-DTRAPFPE` o no usarla está en el manejo de excepciones cuando ocurra un operacion que matematicamente no está definida. Por ejemplo en dividir en cero o calcular la raiz de un numero negativo. Es importante notar que estas operaciones están en punto flotante y segun entiendo se está usando la FPU del microprocesador. Estas excepciones son importantes habilitarlas, ya que un resultado NaN o Inf no necesariamente van a delatar un error, y puede arrastrarse en procesamientos mas complejos. En el programa que se nota esto es en `comparator.c` ya que si se divide por cero en el caso sin flag, el programa da un resultado, bien o mal, pero funciona. En cambio, si esta habilitado el flag, salta el error de division por cero.

# Segmentation Fault

### Pregunta 1

El código `matmult.c` realiza una operacion con una matriz `A` y la guarda en una matriz `C`, las cuales se crean en memoria dinamica. Las matriz `A` es densa y esta formadas por puntos flotantes, de dividir la fila por la columna. La operación, tal como dice en el comentario, es una forma ineficiente de hacer `C = A * AT`, donde `AT` es la transpuesta de `A`. La diferencia cuando se usa el `MakeFile` es que `small.e` se compila con matrices de 100x100 y `big.e` con matrices de 2500x2500.

### Pregunta 2

Antes de hacer `ulimit -s unlimited`, `big.e` devuelve SEGFAULT y `small.e` funciona correctamente. Despues de ejecutarse `ulimit -s unlimited`, `big.e` pudo ejecutarse, aunque demoró mucho tiempo. Este comando lo que hace es aumentar la memoria stack a sin limite, la cual se utilizá para las variables declaradas dentro de las funciones (entre otras cosas), por otro lado esta el heap el cual almacena las matrices A y C cuando se utiliza `malloc()`. Al hacerse el stack sin limite, puede ejecutarse `big.e`, cuando antes daba SEGFAULT porque el stack no alcanzaba para el cálculo, antes utilizarse el comando `ulimit` es de 8192 kilobtyes, espacio insuficiente para dos matrices de 2500x2500 formada por float.

### Pregunta 3

Usar el comando `ulimit -s unlimited` no es una solución en el sentido del debugging ya que se está modificando los parametros del sistema en el que esta funcionando el programa y no el codigo.

### Pregunta 4

Una solución que implementé y funcionó fue declarar static a la variable `temp` de la funcion `mat_Tmat_mul()`. No se si es la mejor, pero logra que se independice del tamaño del stack y a tiempo de compilación ya se guarda cuanta memoria va a ocupar.

# Valgrind

Desarrolle los casos de C.

### test_oob4.c

Para testear este codigo, hice un estudio de memory leackage siguiendo lo que esta en esta pregunta de stackoverflow:

[How do I use valgrind to find memory leaks? - stackoverflow](https://stackoverflow.com/questions/5134891/how-do-i-use-valgrind-to-find-memory-leaks)

Lo compile usando:

~~~~
gcc -Wall -ggdb3 test_oob4.c -o test_oob4_flag.e
~~~~

Ejecute valgrind usando:

~~~~
valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes --verbose --log-file=valgrind-out_flag.txt ./test_oob4_flag.e
~~~~

En todo el reporte que se obtiene en `valgrind-out_flag.txt`, la parte mas interesante fue:

~~~~
==3895== 160,000,000 bytes in 4 blocks are definitely lost in loss record 1 of 2
==3895==    at 0x483877F: malloc (vg_replace_malloc.c:299)
==3895==    by 0x1091A8: mysub (test_oob4.c:10)
==3895==    by 0x10924E: main (test_oob4.c:32)
==3895==
==3895== 200,000,000 bytes in 5 blocks are possibly lost in loss record 2 of 2
==3895==    at 0x483877F: malloc (vg_replace_malloc.c:299)
==3895==    by 0x1091A8: mysub (test_oob4.c:10)
==3895==    by 0x10924E: main (test_oob4.c:32)
~~~~

En donde nos indica que hubo memory leackage y en que zonas se generaron esas memorias (gracias a que use el flag `-ggdb`). Con esa información pude identificar en el codigo que se creaba una memoria dinamica en la función `mysub()`, pero nunca era liberada, por lo que una vez que el puntero usado se volvia a utilizar (en en un nuevo `malloc()`), se perdia la memoria correspondiente. Se corrigio de la siguiente forma:

~~~~c
int main(int argc, char *argv[])
{
 ...
 float lastf = 0.0;

 printf("Insert last \n");
 scanf("%d",&last);
 for(i=0; i<last; i++)
   {
     mysub(&a, mydim);
     lastf = a[0];
     free(a);
   }
   ...
~~~~

### source1.c

En este caso se realizó lo que está escrito en la cabecera del archivo. Al compilarse y ejecutarse, se observa que la memoria crece lentamente pero inexorablemente en algun momento se quedará sin memoria (viendo con el comando `htop` en otra consola).

Para poder ejecutar valgrid y ver el reporte, se quito el loop infinito y se realizo que la función dentro del loop se ejecute una sola vez. Una vez ejecutada, se observó en el reporte `valgrind_source1_flag.txt`

~~~~
==4941== HEAP SUMMARY:
==4941==     in use at exit: 4,000,000 bytes in 1 blocks
==4941==   total heap usage: 3 allocs, 2 frees, 12,000,000 bytes allocated
==4941==
==4941== Searching for pointers to 1 not-freed blocks
==4941== Checked 73,784 bytes
==4941==
==4941== 4,000,000 bytes in 1 blocks are definitely lost in loss record 1 of 1
==4941==    at 0x483877F: malloc (vg_replace_malloc.c:299)
==4941==    by 0x109235: mat_Tmat_mul (source1.c:30)
==4941==    by 0x1090F9: main (source1.c:60)
==4941==
==4941== LEAK SUMMARY:
==4941==    definitely lost: 4,000,000 bytes in 1 blocks
==4941==    indirectly lost: 0 bytes in 0 blocks
==4941==      possibly lost: 0 bytes in 0 blocks
==4941==    still reachable: 0 bytes in 0 blocks
==4941==         suppressed: 0 bytes in 0 blocks
~~~~

En donde se observa en donde ocurrió el memory leackage. Viendo el codigo se observa que la función `mat_Tmat_mul()` genera una memoria dinamica con `malloc()` temporal, pero nunca la libera cuando termina la función. Corregido eso y volviendo a el loop infinito, se observa ahora que la memoria no aumenta aunque se ejecuta durante un tiempo muy largo.
