import controlP5.*;
ControlP5 cp5;
import java.nio.charset.StandardCharsets;
PImage iphonebgimg;
PImage w1_food;  // 식단 위젯 이미지
// 인디케이터 이미지
PImage dots1;
PImage dots2;
// mouse scroll
boolean isLocked = false;
float pos, npos;
// 위젯1 안전/위험 상황
boolean isPlay = false;
// dots 상태를 추적하는 변수
boolean isDots1Active = true;  // true: dots1, false: dots2
// 이미지 변수
PImage safeImage;  // 안전 상황 이미지
PImage riskImage;  // 위험 상황 이미지
// 혈당위젯 : 5초마다 난수(70~170), 140이상=위험혈당이미지
int randomNumber;  // 난수 저장할 변수
PImage safeSugar, riskSugar; // 이미지 변수
int lastTime = 0;   // 마지막으로 난수를 생성한 시간 (밀리초)
int interval = 5000; // 5초 간격
PFont sfpro, sfpro_semibold;
// 러닝위젯
PImage rW_bg, rW_stopBtn, rW_PauseBtn, rW_map, rW_startBtn, rW_newStartBtn;
PImage[] progressImages = new PImage[20]; // 원그래프용 이미지 배열
boolean isRunning = false;
boolean isRunningPause = false;
int startTime = 0;      // 러닝 시작 시간
int elapsedTime = 0;    // 경과 시간 (밀리초)
int walkCounter = 0;  // 걸음수
int walkKcal = 0;  //걸음 소비 칼로리
// 캠핑위젯
PImage campingbg;  //캠핑 위젯 기본 배경 이미지
PImage sche1, sche2, sche3, sche4, currentImg; // 일정 이미지
float buttonX, buttonY, buttonWidth, buttonHeight; // 투명버튼 생성
int sche_btn_clickCount = 0;  // 클릭 횟수 추적
boolean schedulebuttonClicked = false;  // 버튼 클릭 여부
// 약 복용 위젯
PImage mW_image,mW_check;
PImage[] mW_images;
boolean checking = false;
boolean nomorecheck = false;
int currentMWImage = 0;

int checktimer = 0;
boolean timerActive = false;
void setup() {
  size(402, 874);
  
  cp5 = new ControlP5(this);
  
  // 버튼1 혈당그래프 변경
  safeImage = loadImage("위젯1 안전상황.png");
  riskImage = loadImage("위젯1 위험상황.png");
  
  cp5.addButton("playBtn")
     .setPosition(34, 88)
     .setImage(safeImage)  // 기본 이미지 설정
     .updateSize();
  
  dots1 = loadImage("인디케이터1면.png");
  dots2 = loadImage("인디케이터2면.png");
  // dots 버튼 (클릭시 이미지 변경)
  cp5.addButton("dotsBtn")
     .setPosition(377, 154)
     .setImage(dots1)  // 기본 dots1 이미지
     .updateSize();
  
  // 혈당 이미지   
  safeSugar = loadImage("안전혈당.png");
  riskSugar = loadImage("위험혈당.png");
  
  // 초기 난수 생성
  randomNumber = int(random(70, 171)); // 70에서 170까지 난수 생성
  
  iphonebgimg = loadImage("Wallpaper.png");
  campingbg = loadImage("캠핑기본배경.png");
  w1_food = loadImage("식단 위젯.png");  // 식단 이미지 로드
  
  // text
  sfpro = createFont("SF-Pro.ttf",16, true); 
  sfpro_semibold = createFont("SF-Pro-Rounded-Semibold.otf",48,true);
  
  // 캠핑 일정 이미지 로드
  sche1 = loadImage("일정1.png");
  sche2 = loadImage("일정2.png");
  sche3 = loadImage("일정3.png");
  sche4 = loadImage("일정4.png");
  
  // 초기 이미지 설정 (일정1)
  currentImg = sche1;

  //// 버튼의 위치와 크기 설정
  //buttonX = 219;
  //buttonY = 837;
  //buttonWidth = 126;
  //buttonHeight = 32;
  
  ////noStroke();  // 테두리 없애기
  
  // 러닝위젯 이미지
  rW_bg = loadImage("러닝위젯/러닝위젯 배경.png");
  rW_stopBtn = loadImage("러닝위젯/정지버튼.png");
  rW_startBtn = loadImage("러닝위젯/시작버튼.png");
  rW_PauseBtn = loadImage("러닝위젯/일시정지 버튼.png");
  rW_newStartBtn = loadImage("러닝위젯/시작버튼2.png");
  // 러닝위젯 관련 버튼
  cp5.addButton("runningStartBtn")
   .setPosition(265, 464)
   .setImage(rW_startBtn)
   .updateSize();
  cp5.addButton("runningStopBtn")
   .setPosition(303, 464)
   .setImage(rW_stopBtn)
   .updateSize()
   .hide();
  cp5.addButton("runningPauseBtn")
   .setPosition(238, 464)
   .setImage(rW_PauseBtn)
   .updateSize()
   .hide();
  cp5.addButton("runningNewStartBtn")
   .setPosition(238, 464)
   .setImage(rW_newStartBtn)
   .updateSize()
   .hide();
  // 이미지를 배열에 로드
  for (int i = 0; i <= 19; i++) {
    String imagePath = "러닝위젯/progress/" + ((i + 1) * 5) + ".png";  // 5부터 시작
    progressImages[i] = loadImage(imagePath);  // 이미지 로드
  }
  
  //약 복용 위젯 선언
  mW_check = loadImage("약복용위젯/check.png");
  mW_images = new PImage[5];
  mW_images[0] = loadImage("약복용위젯/약복용위젯1.png");
  mW_images[1] = loadImage("약복용위젯/약복용위젯2.png");
  mW_images[2] = loadImage("약복용위젯/약복용위젯3.png");
  mW_images[3] = loadImage("약복용위젯/약복용위젯4.png");
  mW_images[4] = loadImage("약복용위젯/약복용위젯5.png");
  
}
void draw() {
  background(255);  
  
  // 배경 이미지 그리기
  image(iphonebgimg, 0, 0);
  
  npos = constrain(npos, -100, 0);
  pos += (npos - pos) * 0.1;
  
  // 5초마다 난수를 새롭게 생성
  if (millis() - lastTime > interval) {
    lastTime = millis(); // 마지막 난수 생성 시간 갱신
    randomNumber = int(random(70, 171)); // 70에서 170까지 난수 생성
  }
  
  //캠핑 위젯
  pushMatrix(); 
  translate(0, int(pos));
  
  // 위젯 이미지 그리기
  image(campingbg, 34, 580);  // 위젯5 캠핑 위치
  
  // 현재 일정 이미지 표시
  image(currentImg, 203, 763);  
  
  // 버튼의 위치와 크기 설정
  buttonX = 219;
  buttonY = 837 + pos;
  buttonWidth = 126;
  buttonHeight = 32;
  
  noStroke();  // 테두리 없애기
  
  // 투명한 버튼
  fill(0, 0);  // 완전 투명한 색상 (알파 값 0)
  rect(buttonX, buttonY, buttonWidth, buttonHeight);
  
  // 투명 버튼 영역에 클릭된 경우
  if (mousePressed && !schedulebuttonClicked) {  // 버튼이 클릭되지 않은 경우에만 처리
    if (mouseX > buttonX && mouseX < buttonX + buttonWidth &&
        mouseY > buttonY && mouseY < buttonY + buttonHeight) {
      // 클릭된 경우
      if (sche_btn_clickCount == 0) {
        currentImg = sche2;  // 일정2로 변경
      } else if (sche_btn_clickCount == 1) {
        currentImg = sche3;  // 일정3으로 변경
      } else if (sche_btn_clickCount == 2) {
        currentImg = sche4;  // 일정4로 변경
      }
      
      // 클릭 횟수 증가, 일정4 이후에는 더 이상 변경되지 않도록 설정
      if (sche_btn_clickCount < 3) {
        sche_btn_clickCount++;
      }

      schedulebuttonClicked = true;  // 클릭 처리 완료
    }
  }

  // 마우스 클릭이 끝나면 다시 클릭을 받을 수 있게 설정
  if (!mousePressed) {
    schedulebuttonClicked = false;  // 마우스가 떨어지면 버튼 클릭 상태 초기화
  }
  
  
  // dots 버튼 이미지 (현재 dots1 또는 dots2)
  cp5.getController("dotsBtn").setImage(isDots1Active ? dots1 : dots2);
  
  // 버튼 위치 업데이트
  cp5.getController("playBtn").setPosition(34, 88 + pos);
  cp5.getController("dotsBtn").setPosition(377, 154 + pos);

  // 난수에 따라 이미지 교체
  if (randomNumber < 140) {
    image(safeSugar, 34, 482); // randomNumber가 140 미만이면 안전혈당 표시
  } else {
    image(riskSugar, 34, 482); // randomNumber가 140 이상이면 위험혈당 표시
  }
  
  // 난수를 화면에 표시 
  textFont(sfpro_semibold,32);
  fill(0);
  text(randomNumber, 89, 525);
  
  popMatrix();
  
  
  // 러닝 위젯
  pushMatrix(); 
  translate(0, int(pos));

  
  image(rW_bg,214,286);
  
  cp5.getController("runningStartBtn").setPosition(271, 464 + pos);
  cp5.getController("runningStopBtn").setPosition(303, 464 + pos);
  cp5.getController("runningPauseBtn").setPosition(238, 464 + pos);
  cp5.getController("runningNewStartBtn").setPosition(238, 464 + pos);
  
  if (isRunning && !isRunningPause) {
    elapsedTime = (millis() - startTime) / 1000; // 초 단위로 변환
  }
  if (isRunning) {
    int minutes = elapsedTime / 60; // 분
    int seconds = elapsedTime % 60; // 초
    // 경과 시간 출력
    textFont(sfpro, 24);
    fill(0);
    textAlign(LEFT);
    text(String.format("%02d:%02d", minutes, seconds), 265, 335);
  }
  walkKcal = walkCounter / 50;
  int progressIndex = walkCounter / 500; // 500 단위로 인덱스 계산
  if (progressIndex>=20){
  progressIndex = 19;
  }
  progressIndex = min(progressIndex, 20);  // 최대 인덱스 제한 (20)
  if (!isRunning){
  //걸음수와 칼로리 텍스트 표시
  textFont(sfpro, 18);
  fill(255);
  textAlign(RIGHT);
  text(walkCounter, 305,367);
  textFont(sfpro, 10);
  text("걸음", 328,367);
  textFont(sfpro, 15);
  textAlign(RIGHT);
  text(walkKcal + "  kcal", 320,387);
  textAlign(LEFT);
  // 그래프 이미지 표시
  if (progressImages[progressIndex] != null) {
    image(progressImages[progressIndex], 232, 314);
  } else {
    println("Image not found for index: " + progressIndex);
  }
  }
  popMatrix();
  
  
  // 약 복용 위젯
  pushMatrix();
  translate(0, int(pos));
  
  image(mW_images[currentMWImage],34,286);
  if (!nomorecheck){
  fill(255);
  rect(161, 358, 20, 20); // 클릭 가능한 구역
  }
  // 체크하면 체크 이미지 나오도록 설정
  if (checking) { 
  image(mW_check,164,361);
  }
  
  // 체크 후 2초 지나면 다음 이미지 나오게 하기
  if (checking && millis() - checktimer > 1000 && !nomorecheck ){ 
    currentMWImage = currentMWImage +1;
    
    checking = false;
   
    if (currentMWImage == 4){ //이미지 끝까지 가면 체크기능 정지
      nomorecheck = true;
    }
  } 
  popMatrix();
}

void mousePressed() {
  isLocked = true;
  //2초후 체크 사라지도록,,
  if (mouseX > 161 && mouseX <181 && mouseY > 358+int(pos) && mouseY < 378+int(pos) &&!nomorecheck) {
    checking = true; 
    checktimer = millis();
  }

}
void mouseDragged(MouseEvent event) {
  if (isLocked) {
    npos += (mouseY - pmouseY) * 1.5;
  }
}
void mouseReleased() {
  isLocked = false;
}
// dots1 또는 dots2 버튼을 클릭했을 때
public void dotsBtn() {
  // dots 버튼이 클릭되었을 때
  isDots1Active = !isDots1Active;  // 상태 전환
  // 상태에 따라 playBtn 이미지 설정
  if (isDots1Active) {
    cp5.getController("playBtn").setImage(safeImage);  // 안전 이미지로 설정
  } else {
    cp5.getController("playBtn").setImage(w1_food);  // 식단 위젯 이미지로 설정
  }
  // 버튼 이미지 상태를 반영
  cp5.getController("dotsBtn").setImage(isDots1Active ? dots1 : dots2);
}
// 식단1면 클릭시 위험 상태로 전환
public void playBtn() {
  println("위젯1 클릭");
  
  isPlay = !isPlay;  // 상태 전환
  
  // 위험 또는 안전 이미지로 설정
  if (isPlay) {
    cp5.getController("playBtn").setImage(riskImage);  // 위험 상황 이미지로 변경
  } else {
    cp5.getController("playBtn").setImage(safeImage);  // 안전 상황 이미지로 변경
  }
}
// 러닝 시작 버튼
public void runningStartBtn(){
  println("러닝시작위젯 클릭");
  isRunning = true;
  startTime = millis();
  rW_bg = loadImage("러닝위젯/지도.png");
  // 버튼 비활성화
  cp5.getController("runningStartBtn").hide();
  cp5.getController("runningStopBtn").show();
  cp5.getController("runningPauseBtn").show();
  println("시작버튼 비활성화됨");
}
// 러닝 정지 버튼
public void runningStopBtn(){
  isRunning = false;
  rW_bg = loadImage("러닝위젯/러닝위젯 배경.png");
  elapsedTime = 0;
  
  cp5.getController("runningStopBtn").hide();
  cp5.getController("runningPauseBtn").hide();
  cp5.getController("runningNewStartBtn").hide();
  cp5.getController("runningStartBtn").show();
}
//러닝 일시정지 버튼
public void runningPauseBtn() {
  
  // 일시정지 상태로 변경
  isRunningPause = true; // 러닝 상태 종료
  cp5.getController("runningPauseBtn").hide(); // 일시정지 버튼 숨기기
  cp5.getController("runningNewStartBtn").show();
}
//러닝 이어서시작 버튼
public void runningNewStartBtn() {

  // 새로운 시작 버튼 클릭 시, 정지된 시간부터 다시 시작
  startTime = millis() - elapsedTime * 1000; // 이전 타이머 값으로 재시작
  
  // 러닝 상태 재설정
  isRunning = true;
  isRunningPause = false;
  
  // 버튼 상태 변경
  cp5.getController("runningNewStartBtn").hide(); // 새로운 시작 버튼 숨기기
  cp5.getController("runningPauseBtn").show(); // 일시정지 버튼 보이게 하기

}
// 휠업다운시 걸음수 증감
void mouseWheel(MouseEvent event) {
  if (event.getCount() < 0) {
    walkCounter +=55;
  }

  else if (event.getCount() > 0) {
    walkCounter -= 55;
    walkCounter = max(walkCounter, 0);
  }
}
