#include <sys/wait.h>
#include <sys/stat.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>

// global PID to access inside the alarm 
int pids[2];
char loser_label;

// get file size
int get_file_size(char* file_name){
    struct stat st;
    if (stat(file_name, &st) == 0) {
        return st.st_size; 
    } else {
        return -1;
    }
}

// handlers
void child_ex_handler(int sig_num){
    int stat_loc;
    pid_t pid;

    // returns 0 when no more zombies so terminates the while loop 
    while ((pid = waitpid(-1, &stat_loc, WNOHANG)) > 0){

        if(WIFEXITED(stat_loc) && WEXITSTATUS(stat_loc) == 1){
        pid_t loser = (pid == pids[0]) ? pids[1] : pids[0];
        char  label = (pid == pids[0]) ? 'A' : 'B';
        alarm(0);
        printf("Parent: Child %c found the file.\n", label);
        fflush(stdout);
        kill(loser, SIGUSR1);
    }

    }
}

void alarm_handler(int sig_num){
    kill(pids[0] ,SIGTERM);
    kill(pids[1] ,SIGTERM);
}

void term_handler(int sig_num){
    printf("I am the child and I could not find the file.\n");
    fflush(stdout);
    signal(SIGTERM, term_handler);
    exit(0);
}

void loser_sig_handler(int sig_num){
    printf("I am child %c, and I received from my parent that I am the loser.\n", loser_label);
    fflush(stdout);
    exit(0);
}


int main(int argc, char** argv){
    // extracted data
    int size = atoi(argv[1]);
    int num_files = argc - 2;
    int dispacher_pipe[2];
    dispacher_pipe[0] = num_files % 2 == 0 ? num_files / 2 : num_files / 2 + 1;
    dispacher_pipe[1] = num_files / 2;
//    int dispacher2_pipe = num_files / 2;
    char** file_names = argv + 2;

 

    // parent children work
    int start = 0;

    // attach handlers
    signal(SIGCHLD, child_ex_handler);
    signal(SIGALRM , alarm_handler);
    
    //wait 5 seconds
    for(int i = 0 ; i < 2 ; ++i){
        pids[i] = fork();
        if(pids[i] == 0){
            loser_label = (i==0) ? 'A' : 'B';
            signal(SIGTERM, term_handler);
            signal(SIGUSR1,loser_sig_handler);
            for(int j = start ; j < dispacher_pipe[i]+start ; ++j){
                int f_size = get_file_size(file_names[j]);
                if( f_size == size){
                    printf("I found the file at location %d.\n" ,j);
                    fflush(stdout);
                    exit(1);
                }
            }

            pause();

        }else{
            start += dispacher_pipe[i];
        }
    }
    // wait 5 seconds
    alarm(5);
    pause();
    exit(0);
    


}