
int fsrPin0 = A0;// A0 接口
int fsrPin1=A1;
int fsrPin2=A2;
int fsrPin3=A3;
int fsrPin4=A4;
int fsrReading0;
int fsrReading1;
int fsrReading2;
int fsrReading3;
int fsrReading4;

void setup(void) {
  pinMode(fsrPin0,INPUT);
  pinMode(fsrPin1,INPUT);
  pinMode(fsrPin2,INPUT);
  pinMode(fsrPin3,INPUT);
  pinMode(fsrPin4,INPUT);


  Serial.begin(9600);
}
void loop(void) {
  fsrReading0 = analogRead(fsrPin0);
  fsrReading1 = analogRead(fsrPin1);
  fsrReading2 = analogRead(fsrPin2);
  fsrReading3 = analogRead(fsrPin3);
  fsrReading4 = analogRead(fsrPin4);
    if (fsrReading0 > 5) {
    Serial.print(1);
    delay(10);
    }
    if (fsrReading1 > 5) {
    Serial.print(2);
    delay(10);
    }
    if (fsrReading2 > 5) {
    Serial.print(3);
    delay(10);
    }
    if (fsrReading3 > 5) {
    Serial.print(4);
    delay(10);
    }
    if (fsrReading4 > 5) {
    Serial.print(5);
    delay(10);
    }
}
              
