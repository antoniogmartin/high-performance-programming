# include <math.h>
# include <mpi.h>
# include <stdio.h>
# include <stdlib.h>
# include <time.h>

int main ( int argc, char *argv[] );
int prime_number ( int n, int id, int p );


int main ( int argc, char *argv[] )

{
  int i;
  int id;
  int ierr;
  int n;
  int n_factor;
  int n_hi;
  int n_lo;
  int p;
  int primes;
  int primes_part;
  double wtime;
  clock_t start,end;
  double cpu_time_used;
if (argc!=2){

  printf("ERROR: mpirun -np primeV2 <tamanio> argc %i\n",argc);
  }
  else{
      n_lo = 2;
      n_hi = atoi(argv[1]);
      n_factor = 2;
    /*
      Inicializar mpi.
    */
      start=clock();
      ierr = MPI_Init ( &argc, &argv );
      end=clock(); 
    cpu_time_used=((double) (end-start)/(CLOCKS_PER_SEC));
    /*
      Obtener numero de procesos
    */
      ierr = MPI_Comm_size ( MPI_COMM_WORLD, &p );
      ierr = MPI_Comm_rank ( MPI_COMM_WORLD, &id );
    if(p%2==0){
      if(id==0){
        printf("#No balancea bien num. procesos par\n");
      }
      ierr = MPI_Finalize ( );
    }
    else{
        if ( id == 0 )
        {
       /*   timestamp ( );
          printf ( "\n" );
          printf ( "#PRIME_MPI\n" );
          printf ( "# C/MPI version\n" );
          printf ( "#\n" );
          printf ( "# Cantidad total de número de primos en potencias de dos.\n" );
          printf ( "# The number of processes is %d\n", p );
          printf ( "\n" );
          printf ( "#         N^2                  \tNumeroDePrimos         \t Time\n" );
          printf ( "\n" );*/
        }

        n = n_lo;

        while ( n <= n_hi )
        {
          if ( id == 0 )
          {
            wtime = MPI_Wtime ( ); //comenzar reloj
          }
          //bcast :envia un mensaje desde proceso "0" a todos los del grupo,misma cantidad de datos enviados que recibidos
          ierr = MPI_Bcast ( &n, 1, MPI_INT, 0, MPI_COMM_WORLD ); 
          primes_part = prime_number ( n, id, p );

          ierr = MPI_Reduce ( &primes_part, &primes, 1, MPI_INT, MPI_SUM, 0, 
            MPI_COMM_WORLD );

          if ( id == 0 )
          {
            wtime = MPI_Wtime ( ) - wtime; //finalizar reloj
            //printf ( "  %8d        \t%8d        \t%14f\n", n, primes, wtime );
            
          }

          n*=n_factor;
          
        }
    
      start=clock();
        ierr = MPI_Finalize ( );
      end=clock();
      cpu_time_used=cpu_time_used+((double) (end-start)/(CLOCKS_PER_SEC));

      /*
        Terminate.
      */
        if (id == 0 && p%2!=0) 
        {
          printf ( "#%14f\n", wtime );     
          printf ( "#%14f\n\n", cpu_time_used);
          printf ( "%14f\t %d\n\n",cpu_time_used+wtime,p);
        }
  }
}
  return 0;
}
/******************************************************************************/

int prime_number ( int n, int id, int p )

/******************************************************************************/

{
  int i;
  int j;
  int prime;
  int total;

  total = 0;
  //printf("Proceso %d\n",id);
  for ( i = 2 + id; i <= n; i = i + p )
  {
    prime = 1;
    for ( j = 2; j < i; j++ )
    {
      if ( ( i % j ) == 0 )
      {
        prime = 0;
        break;
      }
    }
    total = total + prime;
  }
  return total;
}
/******************************************************************************/


