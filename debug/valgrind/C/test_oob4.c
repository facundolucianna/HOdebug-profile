#include <stdlib.h>
#include <stdio.h>

#define DIM 10000000

void mysub(float **a, int dim)
{
  int j;

  (*a) = (float *)malloc(sizeof(float)*dim);

  for(j=0; j<dim; j++)
    {
      (*a)[j] = 7.;
    }

}



int main(int argc, char *argv[])
{
  float *a;
  int i;
  int mydim = DIM;
  int last;
  float lastf = 0.0;

  printf("Insert last \n");
  scanf("%d",&last);
  for(i=0; i<last; i++)
    {
      mysub(&a, mydim);
      lastf = a[0];
      free(a);
    }

  printf("a = %f \n", lastf);

  return(EXIT_SUCCESS);
}
