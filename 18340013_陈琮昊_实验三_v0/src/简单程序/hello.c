
char Message[10]="AaBbCcDdEe";   
       /*变量_Message,初值为AaBbCcDdEe*/
void upper(){
   for(int i=0;i<10;i++){
          if (Message[i]>='A'&&Message[i]<='Z')  
                Message[i]=Message[i]-'A'+'a';
    }
}



