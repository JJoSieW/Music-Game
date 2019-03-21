/*本程序需要在processing内添加库文件Minim，选择速写本→引用库文件→添加库文件，在Libraries中搜索Minim并下载。*/
/*Rules:
  game1:drum beat
        red ball: press C or B
        blue ball:press D or H
  game2:maze 
        use direction key(up,down,right,left) to 
        control the ball reach the other end of the road.*/
import ddf.minim.*;          //minim库
import processing.serial.*;  //串口库
PImage backimg;              //背景图
int keystate1=0;             //4个按键状态
int keystate2=0;
int keystate3=0;
int keystate4=0;
int imageframe=8;           //击中图片显示的帧数
int imagestate=0;           //击中图片状态
int bcount=0;               //鼓点计数器
int gamechoose=0;
int bgmstate=0;             //音乐状态
int score=0;                   //总分统计
int combo=0;                //连击统计
int df=1;                   //难度
int songnum;                //歌曲编号
int sa;                     //串口读数
int menu=1;
int menu1=0;                //菜单状态 
int menu2=0;
int menu3=0;
int menu4=0;
int menu5=0;
int playstate=0;            //游戏状态
int serialstate=1;          //串口状态
int frame1=0;               //串口敲击时鼓面变化的帧数
int frame2=0;
int frame3=0;
int frame4=0;
int bcolor;                 //连击统计颜色判断
AudioPlayer bgm;            //音乐播放器
Minim mbgm;                 //文件接口
BufferedReader reader;      //鼓点时间文件读取
Minim minim1;               //鼓点音效文件接口
Minim minim2;

AudioSample inside;         //鼓点音效播放接口
AudioSample outside;
String line;                //鼓点时间文件读取行数
Timer timer;                //计时器
Drumbeat[] db=new Drumbeat[40]; //实例化多个鼓点类
Mybutlisten mybut;          //按键监听与鼓面变化类
Drum mydrum;                //大鼓类
PImage img;                 //击中时的图片接口
int mykey;                  //储存当前按键
Serial serial;              //串口初始化
int stime, bstyle, nstime, nbstyle;  //储存map中某行的数据
int[] st;                   //储存对应编号鼓点类的出现时间
String song;                //歌曲文件名
String songmap;             //鼓点时间文件名

int beginX=746;                        //小球起始位置
int beginY=50;                               
color borderColor=color (50, 50, 50);      //迷宫边界颜色
float x, y;                            //运动中小球坐标
int posx_timer,posy_timer;              //读取小球坐标、半径
float radius_timer;                     
int startTime;                         //计时开始时间
float endTime;                        //计时结束时间
Mission1 mission1;                    //第一关地图
Mission2 mission2;                    //第二关地图
CURRENTRecord currentRecord1;       //第一关记录
CURRENTRecord currentRecord2;       //第二关记录
int missionNo=0;                      //选择的关卡号
Ball ball;                             //小球相关参数
Timer1 timer_record;                   //记录存档 
int n=0;                              //判断选择记录显示内容
int m1=0,m2=0;
AudioPlayer bgm2;                    //音乐播放器
String song2;
int bgmstate2=0;
Minim mbgm2;
 
 
   void setup()
   {
     println(Serial.list());
       try {
           serial=new Serial(this, "COM4", 9600);        
             //设置串口, 在Arduino找对应的端口号
       }
       catch (Exception e) {
           println("没有连接到Arduino设备");
           serialstate=0;                     //不启用串口敲击判断
       }
       PFont font = createFont("黑体", 25);   //字体设置
       textFont(font); 
       backimg=loadImage("background.png");   //背景图片
       backimg.resize(800,800);
       mbgm=new Minim(this);                  //实例化背景音乐minim类
       imageMode(CENTER);                     //图片绘制起点设置为中心
       img = loadImage("taiko-hit300.png");   //读取击中图片
       minim1=new Minim(this);                //实例化鼓点音效minim类
       minim2=new Minim(this);
       mybut=new Mybutlisten('c', 'b', 'd', 'h');
         //定义键盘按键, c、b为鼓面(红), d、h为鼓边(蓝)
       mydrum=new Drum(100, 225, 100, 100);   //鼓面
       st=new int[50];                        //数组实例化
       for (int k=0; k<40; k++)
           db[k]=new Drumbeat();              //实例化40个鼓点
       frameRate(120);
       size(800, 800);
       timer=new Timer();
       inside=minim1.loadSample("in.wav", 512); //读取鼓点音效
       outside=minim2.loadSample("out.wav", 512);
       ball=new Ball(beginX, beginY, 20, borderColor);
       currentRecord1=new CURRENTRecord();
       currentRecord2=new CURRENTRecord();
       timer_record=new Timer1();
       mbgm2=new Minim(this);
       bgm2=mbgm2.loadFile("5.mp3");
   } 

   
   void draw()
   {
       background(backimg);                    //背景

      if(menu==1)
       {   fill(0, 102, 153);
           textSize(25);
           text("游戏选择", 620, 120);
           text("A.音乐打击", 600,170);
           text("B.音乐小球", 600,220);
                      if (keyPressed)
               if (key=='a'||key=='A')
               {
                   gamechoose=1;                       
                   menu=0;                    
                   menu1=1;                    
               }
           if (key=='b'||key=='B')
           {
               gamechoose=2;
               menu=0;
              menu3=1;
           }
       }
       if (playstate==1)
         {  playsetup();
          }
       fill(#000000);
       if (menu1==1&&gamechoose==1)                           //一级菜单
       {
     fill(0, 102, 153);
           text("选择难度", 0, 20);
           text("1.普通", 100, 20);
           text("2.困难", 200, 20);
           text("q.返回选择界面",200,50);
           if (keyPressed)
               if (key=='1')
               {
                   df=1;                       // 1为普通,2为困难
                   menu1=0;                    //关闭一级菜单
                   menu2=1;                    //开启二级菜单
               }
           if (key=='2')
           {
               df=2;
               menu1=0;
               menu2=1;
           }
           if(key=='q'||key=='Q')
           {df=1;
           menu=1;
           menu1=0;
           menu2=0;
           gamechoose=0;
           menu3=0;
           menu4=0;
           menu5=0;
           }
       }
    
      if (menu2==1&&gamechoose==1)                           //二级菜单
      {
          fill(0, 102, 153);
          text("选择歌曲", 0, 20);
          text("3.千本樱", 100, 20);
          text("4.妖精的尾巴", 350, 20);
          text("5.红莲の弓矢", 100, 50);
          text("6.FLYING FAFNIR ", 350, 50);
          if (keyPressed)
              if (key=='3')
              {
                  songnum=1;
    
                  menu2=0;
              }
          if (key=='4')
          {
              songnum=2;
              menu2=0;
          }
          if (key=='5')
          {
              songnum=3;
              menu2=0;
          }
          if (key=='6')
          {
              songnum=4;
              menu2=0;
          }
      }
      if (menu2==0&&menu1==0&&gamechoose==1)        //三级菜单
      {
          fill(0, 102, 153);
          text("7.开始游戏", 0, 20);
          text("8.重新开始", 150, 20);
          text("9.返回菜单", 300, 20);
          text("连击统计：", 100, 50);
          text("得分：",100, 100);
          
          if (keyPressed)
          {
              if (key=='9')                  //返回一级菜单
              {
                  stime=0;
                  nstime=0;
                  bcount=0;
                  for (int i=0; i<39; i++)
                  {
                      db[i].resetbeat(i);
                   }
                  timer.timereset();
                  menu1=1;
                  bgmstate=0;
                  playstate=0;
                  bgm.pause();
                  /*for (int i=0; i<39; i++)
                  {
                      db[i].resetbeat(i);
                  }*/
              }
              if (key=='7'&&playstate!=1&&menu1==0)        //开始游戏
              {
                  songselect(songnum);
                  bgm=mbgm.loadFile(song, 1024);                //读取音频文件
    
              reader=createReader(songmap);    //读取map
              firstread();
              playgame();
          } else if (key=='8')                 //重新开始
          {
              stime=0;
              nstime=0;
              try {
                  reader.close();                //释放文件缓存
              }
              catch(Exception e)
              {
                  println("close file error");
              }
              if (bgmstate==0)
              {
                  bgm=mbgm.loadFile(song, 1024);                //读取音频文件
                  bgm.play();
              }
              
              reader=createReader(songmap);   
              bgm.rewind();
              timer.timereset();
              for (int i=0; i<39; i++)        //重置所有鼓点
              {
                  db[i].resetbeat(i);
              }
              bcount=0;
              score=0;
              combo=0;
              firstread();
              /*timer.timereset();*/
              timer.start();
              bgmstate=1;
              playstate=1;
              /*for (int i=0; i<39; i++)        //重置所有鼓点
              {
                  db[i].resetbeat(i);
              }*/
          }
      }
  }
  if (timer.showtime(stime, timer.now())&&bgmstate==1)
     //使用自定义计时器,并判断鼓点是否应该出现
       
  {
  
      if (bgmstate==1)
      try {
          line = reader.readLine();        //读取map文件下一行
      } 
      catch (IOException e) {
          e.printStackTrace();
          line = null;
      }
      if (line!=null)        //读取成功后储存鼓点出现的时间与类型 
      {
          String data[]=split(line, ',');
          println(data[0]);
          nstime=int(data[0]);        //下一个鼓点出现时间
          nbstyle=int(data[1]);       //下一个鼓点类型
      } else {
          timer.timereset();          //map读取完后重置timer, 游戏停止
          bgmstate=0;
          bgm.pause();
          
          try {
              reader.close();
          }
          catch(Exception e)
          {
              println("close erro");
          }
      }
          db[bcount].resetbeat(bcount);   //初始化对应鼓点
          st[bcount]=bstyle;              //储存对应的鼓点类型
          bcount=(bcount+1)%40;
          println(bcount);
      }
      if (playstate==1)                   //游戏中
          for (int i=0; i<39; i++)     //每个鼓点移动
          {
              act(i);
          }
      if (stime!=nstime)                  //下一行数据赋值
      {
          stime=nstime;
          bstyle=nbstyle;
      }
    
      if (imagestate==1&&imageframe>0)  //击中鼓点持续显示图片
      {
          image(img, 250, 220, 100, 100);
          imageframe--;
      } else {
          imagestate=0;
      }
      
if(menu==0&&menu3==1&&menu4==0&&menu5==0&&gamechoose==2) 
//选择游戏二        
    {
        fill(0,102,153);
        textSize(25);
        text("W.开始",20,20);
        text("S.记录",120,20);  
        text("q.返回主页面",20,50);
        if(keyPressed)
        {
            if(key=='w'||key=='W')
            {
                menu3=0;
                menu4=1;
                menu5=0;
            }
            if(key=='s'||key=='S')
            {
                menu3=0;
                menu4=0;
                menu5=1;
            }
           if(key=='q')
           {
           df=1;
           menu=1;
           menu1=0;
           menu2=0;
           gamechoose=0;
           menu3=0;
           menu4=0;
           menu5=0;
           }
        }
    }        
    if(menu4==1&&gamechoose==2)                    //选择关卡    
{
        background(backimg);
        fill(153,102,0);
        textSize(30);
        text("A.Mission 1",500,170); 
        text("D.Mission 2",500,230); 
        if(keyPressed)
        {
            if(key=='a'||key=='A')
            {
                menu3=0;
                menu4=0;
                menu5=0;
                missionNo=1;
            }
            if(key=='d'||key=='D')
            {
                menu3=0;
                menu4=0;
                menu5=0;
                missionNo=2;

            }   
        }
        fill(0,210,200);
        textSize(25);
        text("Press 'R' to return",20,50);
        if(key=='r'||key=='R')
        {
            key='a';
            menu3=1;
            menu4=0;
            menu5=0;   
        }
    }
 if(menu5==1&&gamechoose==2)                              //查看记录
    {
        background(backimg);
        fill(0,102,153);
        textSize(35);
        text("Record",500,230);
        textSize(25);
        if(m1==0&&m2==0)
        {
            text("Mission 1   "+"no record",270,520);
            text("Mission 2   "+"no record",270,570);  
        }
        else if(m1==1&&m2==0)
        {
            text("Mission 1   "+currentRecord1.currentRecord+" s",300,520);
            text("Mission 2   "+"no record",270,570);         
        }
        else if(m1==0&&m2==1)
        {
            text("Mission 1   "+"no record",270,520);
            text("Mission 2   "+currentRecord2.currentRecord+" s",300,570);         
        }
        else if(m1==1&&m2==1)
        {
             text("Mission 1   "+currentRecord1.currentRecord+" s",300,520);
             text("Mission 2   "+currentRecord2.currentRecord+" s",300,570);        
        }
        else
        {
              textSize(30);
              text("Error",360,400);
        }
        textSize(25);
        text("Press 'R' to return",20,50);
        if(key=='r'||key=='R')
        {
            key='a';
            menu3=1;
            menu4=0;
            menu5=0;   
        }
                    
    }
    if(missionNo!=0)                                         //关卡一
    {   
        switch(missionNo)
        {
            case 1:
             bgm2.play();
                m1=1;
                mission1=new Mission1(); 
                //timer_record=new Timer();
                if(n==0)
                {
                    timer_record.start1();                     //计时开始
                    startTime=timer_record.start1();
                    n++;                              
                    //println("n1="+n);
                }
                background(204);                
                mission1.display();   
                ball.update(x, y);
                if(posy_timer==774&&(posx_timer>=5)&&(posx_timer<=100))
                {
                    if(n==1)
                    {
                        currentRecord1.lastRecord=timer_record.stop();
                        //println("entered"+currentRecord1.lastRecord);
                        n++;                         
                    }
                    win();                               //通关，显示成绩
                    textSize(30);
                    text("Time:  "+currentRecord1.lastRecord+"s",460,450);  
                    currentRecord1.judge();                  //更新游戏记录
                    //println("currentrecord1="+currentRecord1.currentRecord);
                    //println("lastrecord1="+currentRecord1.lastRecord);
                    if(n==2)                         //恢复小球参数至初始状态
                    {
                        if(key=='r'||key=='R')
                        {
                            key='a';
                          bgm2.pause();
                            ball.reset();
                        }
                    }
                }
                break;
            case 2:                                            //关卡二
             bgm2.play();
                m2=1;
                mission2=new Mission2(); 
                if(n==0)
                {
                    timer_record.start1();
                    startTime=timer_record.start1();
                    n++;                              //n=1
                    //println("n1="+n);
                }
                background(204);                
                mission2.display();   
                ball.update(x, y);
                if(posy_timer==774&&(posx_timer>=5)&&(posx_timer<=100))
                {
                    if(n==1)
                    {
                        currentRecord2.lastRecord=timer_record.stop();
                        //println("entered"+currentRecord2.lastRecord);
                        n++;                             //n=2
                    }
                    win();
                    textSize(30);
                    text("Time:  "+currentRecord2.lastRecord+"s",460,450);  
                    //println("n2="+n);   
                    currentRecord2.judge();
                    //println("currentrecord2="+currentRecord2.currentRecord);
                    //println("lastrecord2="+currentRecord2.lastRecord);
                    if(n==2)
                    {
                        if(key=='r'||key=='R')
                        {
                            key='a';
                            bgm2.pause();
                            ball.reset();
                        }
                    }
                }
                break;
             default:break;
        } 
    }
              
}
  void keyReleased()
  {
      keystate1=0;                         //重置按键状态
      keystate2=0;
      keystate3=0;
      keystate4=0;
  }
  void keyPressed()
  {
      mykey=mybut.listenbut();   //获取当前按键, 1、2为鼓面, 3、4为鼓边
  }
  void playsetup()
  {
      stroke(0);                      //边缘
      strokeWeight(1);                //边缘粗细
      fill(100, 160);
      rect(0, 150, 800, 150);
      line(200, 150, 200, 300);
      stroke(255);
      strokeWeight(2);
      fill(100);
      ellipse(250, 220, 50, 50);        //灰色敲击点
      fill(0, 102, 153);
      text(combo, 300, 50);             //初始连击计数0
      text(score, 300, 100);             //初始得分0
      mydrum.displaydrum();             //左鼓界面绘制
      mydrum.hitten(mykey);             //鼓面变化
      serialsetup();                    //串口控制
  }
  void act(int n)                       //每一帧的动作
  {
      db[n].showbeat(st[n]);            //显示对应类型的鼓点
      db[n].move();                     //鼓点移动
  }
  void serialsetup()                    //串口敲击时鼓面变化处理
  {
      if (serialstate==1)               //读取串口成功
     {
          sa=serial.read();             //读取串口的值
    
          if (sa==49)                   // 1的ASCII码
          {
              bcolor=0;                 //颜色
              mydrum.serialhitten(1);   //左鼓面
              frame1=8;                 //显示帧数
          }
          if (frame1>0)              //鼓面变化持续一定帧数
          {
              fill(0);
              arc(100, 225, 100, 100, HALF_PI, HALF_PI+PI);
              frame1--;
          }
          if (sa==50)
          {
              bcolor=0;
              mydrum.serialhitten(2);   //右鼓面
              frame2=8;
          }
          if (frame2>0)
          {
              fill(0);
              arc(100, 225, 100, 100, 3*HALF_PI, 3*HALF_PI+PI);
              frame2--;
          }
      
          if (sa==51)
          {
              bcolor=8;
              mydrum.serialhitten(3);   //左鼓边
              frame3=8;
          }
          if (frame3>0)
          {
              stroke(0);
              fill(#F01111);
              arc(100, 225, 100, 100, HALF_PI, HALF_PI+PI);
              frame3--;
          }
          if (sa==52)        
          {
              bcolor=8;
              mydrum.serialhitten(4);   //右鼓边
              frame4=8;
          }
          if (frame4>0)
          {
              stroke(0);
              fill(#F01111);
              arc(100, 225, 100, 100, 3*HALF_PI, 3*HALF_PI+PI);
              frame4--;
          }
      }
  }
  void playgame()
  {
      combo=0;
      score=0;
      playstate=1;             //游戏状态
      playstate=1;             //游戏状态
      bgm.setGain(-10);        //背景音量
      bgm.play();              //播放音乐
      timer.start();           //计时器开始工作
      bgmstate=1;              //音乐状态为1(播放)
  }
  void firstread()             //读取第一行数据
  {
      try {
          line = reader.readLine();  //读取第一行
      } 
      catch (IOException e) {
          e.printStackTrace();
          line = null;
      }
      String data[]=split(line, ',');  //数据以逗号为分隔放入data数组
      stime=int(data[0]);          //出现时间
      println(stime);
      bstyle=int(data[1]);             //鼓点类型
       }
  void songselect(int songn)           //歌曲选择
  {
      if (songn==1)
      {
          song="1.mp3";                //读取音频文件
          if (df==1)
              songmap="1.1.txt";       //读取map
          else
              songmap="1.2.txt";
      }
      if (songn==2)
      {
          song="2.mp3";                //读取音频文件
          if (df==1)
              songmap="2.1.txt";       //读取map
          else
              songmap="2.2.txt";
      }
      if (songn==3)
      {
          song="3.mp3";                //读取音频文件
          if (df==1)
              songmap="3.1.txt";       //读取map
          else
              songmap="3.2.txt";
      }
      if (songn==4)
      {
          song="4.mp3";                //读取音频文件
          if (df==1)
              songmap="4.1.txt";       //读取map
          else
             songmap="4.2.txt";
      }
  }

        class Drumbeat
        {
            float x=-50;                 //初始坐标
            float y=225;
            float speed=5;               //每帧移动距离
            int fx;                      //击中时坐标
            int fy;
            int sx;                      //miss时的坐标
            int sy;
            int tx;                     //终点坐标
            int ty;
           int dcolor;                 //敲击颜色
            int combostate;             //连击状态
            int num;                    //鼓点编号
            int missstate;              //错误鼓点
        
            void resetbeat(int nums)
            {
                x=825;                  //运动前初始坐标
                y=225;
                speed=5;                //每帧移动5像素
                combostate=0;           //连击状态
                num=nums;
                missstate=0;            //错误鼓点
            }
            float drumx()               //返回当前鼓点x坐标
            {
                return x;
            }
            void showbeat(int s)        //显示对应颜色鼓点
            { 
                if (s==0||s==4)
                {
                    dcolor=0;
                    stroke(255);
                    strokeWeight(5);
                    fill(#F01111);      //红色
                    ellipse(x, y, 50, 50);
                } else if (s==8||s==12)
                {
                    dcolor=8;
                    stroke(255);
                    strokeWeight(5);
                    fill(#0A9CFA);      //蓝色
                    ellipse(x, y, 50, 50);
                }
            }
        
            void move()                 //鼓点移动
            {
        
                if (x>-50)
                    x=x-speed;
                if (x-250<50&&x-250>-50)  
                                         //连击统计
                    if (dcolor==bcolor)
                        if (keyPressed&&combostate==0||serialstate==1&&sa!=-1)
                        {
                            imagestate=1;  //激活图片
                            imageframe=8;  //图片显示帧数
                            combo++;       //连击统计数加一
                            combostate=1;  //激活连击状态
                            fill(0, 102, 153);
                            text(combo, 100, 100);             //显示连击统计数
                            score++;
                        }
                if (x-250<-60&&combostate==0&&missstate==0)        //连击中断
                {
                    combo=0;
                    missstate=1;
                }
            }
        }

        class Drum        //鼓面类
        {
            int x;        //鼓面坐标
            int y;
            int rl;       //左半径
            int rr;       //右半径
            Drum(int a, int b, int c, int d)        //构造函数
            {
                x=a;
                y=b;
                rl=c;
                rr=d;
            }
            void displaydrum()                     //显示鼓面
            { 
                fill(#F01111);
                strokeWeight(8);
                stroke(#0A9CFA);
                arc(x, y, rl, rr, HALF_PI, HALF_PI+PI);
                arc(x, y, rl, rr, 3*HALF_PI, 3*HALF_PI+PI);
            }
            void serialhitten(int u)                //串口敲击判断
            {
                if (u==1)
                { 
                    fill(0);
                    arc(x, y, rl, rr, HALF_PI, HALF_PI+PI);        //左鼓面
                    inside.trigger();                        //播放鼓声
                    keystate1=1;
                } else if (u==2)
                {
                    fill(0);
                    arc(x, y, rl, rr, 3*HALF_PI, 3*HALF_PI+PI);        //右鼓面
                    inside.trigger();
                    keystate2=1;
                } else if (u==3)
                {
                    stroke(0);
                    fill(#F01111);
                    arc(x, y, rl, rr, HALF_PI, HALF_PI+PI);             //左鼓边
                    outside.trigger();
                    keystate3=1;
                } else if (u==4)
                {
                    stroke(0);
                    fill(#F01111);
                    arc(x, y, rl, rr, 3*HALF_PI, 3*HALF_PI+PI);        //右鼓边
                    outside.trigger();
                    keystate4=1;
                }
            }
            void hitten(int u)        //按键敲击判断
            {
                if (keyPressed)
                {
                    if (u==1)
                    {
                        fill(0);
                        arc(x, y, rl, rr, HALF_PI, HALF_PI+PI);
                        if (keystate1==0)
                            inside.trigger();
                        keystate1=1;
                    } else if (u==2)
                {
                fill(0);
                arc(x, y, rl, rr, 3*HALF_PI, 3*HALF_PI+PI);
                if (keystate2==0)                    inside.trigger();
                keystate2=1;
            } else if (u==3)
            {
                stroke(0);
                fill(#F01111);
                arc(x, y, rl, rr, HALF_PI, HALF_PI+PI);
                if (keystate3==0)
                    outside.trigger();
                keystate3=1;
            } else if (u==4)
            {
                stroke(0);
                fill(#F01111);
                arc(x, y, rl, rr, 3*HALF_PI, 3*HALF_PI+PI);
                if (keystate4==0)
                    outside.trigger();
                keystate4=1;
            }
            
     }
   }
  }

       class Mybutlisten     //按键监听类
       {
           char inl;         //左内鼓面
           char inr;         //右内鼓面
           char outl;        //左鼓边
           char outr;        //右鼓边
            Mybutlisten(char a, char b, char c, char d)        //设置按键
            { 
                inl=a;
                inr=b;
                outl=c;
                outr=d;
            }
            int listenbut()          //监听按键
            {
                if (key==inl)
                {
                    bcolor=0;        //0代表红色, 8代表蓝色
                    return 1;
                } else if (key==inr)
                {
                    bcolor=0;
                    return 2;
                } else if (key==outl)
                {
                   bcolor=8;
                    return 3;
                } else if (key==outr)
                {
                    bcolor=8;
                    return 4;
                } else
                    return 0;
            }
        }

       class Timer
       {
            float savedtime;         //计时器何时开始
          int timestate=0;
           void start() {
               //当计时器开启, 它将当前时间以毫秒为单位存储下来
               savedtime = millis();
               timestate=1;
           }
            boolean showtime(float showtimes, float nt)        //判断鼓点是否应该出现
            {
                float passedtime = nt;
               if ((showtimes-940)<=passedtime&&timestate==1)
                {
                  return true;
                } else {
              
                     return false;
               }
            }
            void timereset()   //重置计时器
            {
                timestate=0;
                savedtime=0;
            }
           float now()        //返回计时器运行的时间
            {
                return millis()-savedtime;
            }
       }
       
class Mission1                   //小球第一关地图
{                                  
    void display() 
    {
        background(backimg);     //背景
        rectMode(CORNER);      //障碍物形状位置      
        fill(borderColor);                      
        noStroke(); 
        rect(102, 279, 73, 700, 7);                   
        rect(276, 0, 73, 650,7);
        rect(451, 100, 73, 700,7);
        rect(625, 0, 73, 700,7);
        rect(0, 0, 800, 5);                  
        rect(0, 795, 800, 5);
        rect(0, 0, 5, 800);
        rect(795, 0, 5, 880);
        fill(255);
        stroke(0);
    }
}

class Mission2                        //小球第二关地图
{ 
    void display() 
    {
        background(backimg);
        fill(borderColor);                      
        noStroke();                              
        beginShape();
        vertex(200,100);
        vertex(795,100);
        vertex(795,795);
        vertex(100,795);
        vertex(100,500);
        vertex(200,500);
        vertex(200,700);
        vertex(700,700);
        vertex(700,200);
        vertex(200,200);
        endShape(CLOSE); 
        
        beginShape();
        vertex(5,300);
        vertex(600,300);
        vertex(600,600);
        vertex(300,600);
        vertex(300,500);
        vertex(500,500);
        vertex(500,400); 
        vertex(500,400);
        vertex(5,400);
        endShape(CLOSE);
        
        rectMode(CORNER); 
        rect(0, 0, 800, 5);   
        rect(0, 795, 800, 5);
        rect(0, 0, 5, 800);
        rect(795, 0, 5, 880);
        fill(255);
        stroke(0);
    }
}

class Ball {                                        //小球参数           
    private int posx, posy;                                 
    private float radius;                          
    private float dx;               
    private float dy;               
    private boolean border;        
    private color d;                
    Ball(int posx, int posy, int radius, color e ){            //小球坐标
        this.posx=posx;
        this.posy=posy;
        this.radius=radius;
        this.d=e;
    }
    void display() {                              //小球显示
        fill(0, 100, 0);               
        ellipseMode(RADIUS);
        ellipse(posx, posy, radius, radius);               
        fill(255);
        posx_timer=posx;
        posy_timer=posy;
        radius_timer=radius;
    }

    void move() {                               //遇障碍物速度减为零
        if (isXLeftBorderDetective())         
            if (dx>0)
            dx=0;
        if (isXRightBorderDetective())       
            if (dx<0) 
                dx=0;
        if (isYUpBorderDetective())           
            if (dy<0) 
                dy=0;
        if (isYDownBorderDetective())          
            if (dy>0) 
                dy=0;
        posx-=dx;                               
        posy+=dy;                               
    }

//通过键盘或压力传感器输入控制小球速度及运动方向
 void update(float ax, float ay) {        
      if(keyPressed && (key == CODED)||serialstate==1)
        {   
          if(serialstate==1)
        {
          sa=serial.read();
        } 
        if(keyCode == LEFT||sa==49)
            {
                dx = 2;
            }
            if(keyCode == RIGHT||sa==50)
            {
                dx = -2;
            }
            if(keyCode == UP||sa==51)
            {
                dy = -2;
            }
            if(keyCode == DOWN||sa==52)
            {
                dy = 2;
            }
        } 
        move();                                  
        display();                             
    }

    void reset()                   //通关后小球恢复初始参数
    {
        posx=beginX;
        posy=beginY;
        n=0;
        missionNo=0;
        posx_timer=0;
        posy_timer=0;
        radius_timer=0;
        menu3=1;
        menu4=0;
        menu5=0;
    }

//判断小球是否触界
    boolean isXLeftBorderDetective() {             //判断小球左侧是否触界
        border=false;
        color c;
        c=get((int)(posx-radius-1), (int)posy);
        if (d==c)
            border=true;
        return border;
    }
    boolean isXRightBorderDetective() {            //判断小球右侧是否触界
        border=false;
        color c;
        c=get((int)(posx+radius+1), (int)posy);
        if (d==c)
            border=true;
        return border;
    }
    boolean isYUpBorderDetective() {               //判断小球上侧是否触界
        border=false;
        color c;
        c=get((int)(posx), (int)(posy-radius-1));
        if (d==c)
            border=true;
        return border;
    }
    boolean isYDownBorderDetective() {             //判断小球下侧是否触界
        border=false;
        color c;
        c=get((int)(posx), (int)(posy+radius+1));
        if (d==c)
            border=true;
        return border;
    }
}

class Timer1                                    //计时器
{ 
    int savedTime;                               //储存开始时间
    int passedTime;                               //储存经过时长
    Timer1() {
    }
   int start1()                                     //开始计时
    {
        savedTime = millis(); 
        return millis();
    }
    int stop()                                     //结束计时
    {
        passedTime = millis()-startTime;
        return passedTime/1000;                     //返回通关时间
    }
}
void win()                                          //显示通关画面
{
    background(backimg);
    fill(0,102,153);
    textSize(25);
    text("Press 'R' to return",20,50);                    
    textSize(50);
    text("FINISH",520,280);  
}

class CURRENTRecord                          //保存记录
{
    int lastRecord=10000;
    int currentRecord=10000;
    CURRENTRecord(){
    }
    void judge()                      //判断此次通关时间是否大于以前保存的记录
    {
        if(lastRecord<currentRecord)
        currentRecord=lastRecord;       //更新记录
    }
}      
