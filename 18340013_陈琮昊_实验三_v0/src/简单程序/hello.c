
char Message[10]="AaBbCcDdEe";   
       /*����_Message,��ֵΪAaBbCcDdEe*/
void upper(){
   for(int i=0;i<10;i++){
          if (Message[i]>='A'&&Message[i]<='Z')  
                Message[i]=Message[i]-'A'+'a';
    }
}



