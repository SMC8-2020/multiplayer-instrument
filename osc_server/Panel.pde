public class Panel {

  private int x, y, w, h;
  private color c;
  private String title;

  private static final int headerh = 9;
  private static final int marginver = 9;
  private static final int marginhor = 8;

  public Panel(int x, int y, int w, int h, color c, String title) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.c = c;
    this.title = title;
  }

  public Panel(Panel parent, int h, color c, String title) {
    this.x = parent.x+marginhor;
    this.y = parent.y+headerh+1+marginver;
    this.w = parent.w-marginhor*2;
    this.h = h;
    this.c = c;
    this.title = title;
  }

  public int nextBelow() {
    return y + h + marginver;
  }

  public int nextLeft() {
    return x + w + marginhor;
  }

  void adjustHeightToSibling(Panel p) {
    h = p.nextBelow() - Panel.headerh - 1;
  }

  void adjustHeightToParent(Panel p) {
    h = p.y + p.h - marginver -y;
  }

  void toScreenBottom() {
    h = height - marginver - y;
  }

  void toScreenRight() {
    w = width - marginhor - x;
  }

  public PVector canvasOrigin() {
    return new PVector(x+marginhor, y+headerh+1+marginver);
  }

  public PVector canvasCenter() {
    return new PVector(x+w/2, y+headerh+2+(h-headerh-1)/2);
  }


  public void draw() {
    noStroke();
    fill(HEADER);
    rect(x, y, w, headerh);
    fill(c);
    rect(x, y+headerh+1, w, h-headerh-1);

    fill(TITLE);
    textFont(monoMini);
    text(this.title, x+3, y-1);
  }
}
