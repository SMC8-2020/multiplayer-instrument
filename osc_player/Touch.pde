public class Touch {

  private PVector coordinates;
  private int life;
  private int maxLife;
  
  Touch(PVector coordinates, int life) {
    this.coordinates = PVector.mult(coordinates, 0.3965);
    this.life = life;    
    this.maxLife = life;
  }
  
  void update() {
    life--;
  }
  
  boolean isDead() {
    return life <=0 ;
  }
  
  void draw(){
    fill(255, map(life,0,maxLife,0,255));
    circle(coordinates.x, coordinates.y, 15);
  }
  
}
