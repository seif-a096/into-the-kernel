#include <stdlib.h>
#include<stdio.h>
#include <unistd.h>
#include <sys/wait.h>

 struct order{
        int items;
        int price;
    };

int get_free(struct order* order_arr ,int size ,int v){
    int free_orders = 0;
    for(int i = 0 ; i < size ; ++i){
        if(order_arr[i].items * order_arr[i].price >= v) ++free_orders;
    }
    return free_orders;
}

int main(int argc , char* argv[]){
    // reading args
    char* filename = argv[1];
    int n = atoi(argv[2]);
    int v = atoi(argv[3]);

   
    // file
    char line[256];
    int m;
    FILE* file = fopen(filename ,"r");
    fgets(line , sizeof(line) , file);
    sscanf(line ,"%d" , &m);


    //holders
    int* out_puts = malloc(n * sizeof(int));
    int free_orders;
    struct order temp_order;
    int items ,price ,size ,stat_loc ,cid;
   

    // forking dispachers
    int dispacth_orders = m/n;
    int max_orders = (m + n - 1) / n;
    int pids[n];
    for(int i = 0 ; i < n ; ++i){
        struct order* orders_arr = malloc(max_orders * sizeof(struct order));
        size = 0;

        int start = i * dispacth_orders;
        int end = (i == n - 1) ? m : start + dispacth_orders;

        for (int j = start; j < end; ++j) {
            fgets(line, sizeof(line), file);
            sscanf(line, "%d %d", &items, &price);
            temp_order.items = items;
            temp_order.price = price;
            orders_arr[size] = temp_order;
            size++;
        }

        pids[i] = fork();
        if(pids[i] == 0){
            free_orders = get_free(orders_arr ,size ,v);
            exit(free_orders);
        }else{
            free(orders_arr);
        }
    }

    for(int i = 0; i < n; ++i){
        waitpid(pids[i], &stat_loc, 0);
        if(WIFEXITED(stat_loc)){
        out_puts[i] = WEXITSTATUS(stat_loc);
        }
    }

    for(int i = 0 ; i < n ; ++i ){
        if(i == n-1) printf("%d\n",out_puts[i]);
        else printf("%d ",out_puts[i]);
    }

    fclose(file);
    free(out_puts);



    
    return 0;
}