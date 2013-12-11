import 'dart:html';
import 'dart:async';
import 'dart:svg';

class BasicUnit {
  
  SvgSvgElement canvas;
  GElement group;
  RectElement body;
  bool dragging;
  num dragOffsetX, dragOffsetY, width, height;
  
  var onMouseUpListener, onMouseMoveListener, onMouseLeaveListener;
  
  BasicUnit(SvgSvgElement this.canvas, num x, num y, num this.width, num this.height) {
    body = new RectElement();
    body.setAttribute('x', '$x');
    body.setAttribute('y', '$y');
    body.setAttribute('width', '$width');
    body.setAttribute('height', '$height');
    body.classes.add('processing_body');
    
    body.onMouseDown.listen(select);

    
    group = new GElement();
    group.append(body);
    
    dragging = false;
  }
  
  void select(MouseEvent e) {
    e.preventDefault();
    dragging = true;
    onMouseUpListener = canvas.onMouseUp.listen(moveCompleted);
    onMouseMoveListener = canvas.onMouseMove.listen(moveStarted);
    onMouseLeaveListener = canvas.onMouseLeave.listen(moveCompleted);
    
    var mouseCoordinates = getMouseCoordinates(e);
    dragOffsetX = mouseCoordinates['x'] - body.getCtm().e; //double.parse(body.attributes['x']);
    dragOffsetY = mouseCoordinates['y'] - body.getCtm().f;
  }
  
  void moveStarted(MouseEvent e) {
    e.preventDefault();
    
    if (dragging) {
      var mouseCoordinates = getMouseCoordinates(e);
      num newX = mouseCoordinates['x'] - dragOffsetX;
      num newY = mouseCoordinates['y'] - dragOffsetY;
      body.setAttribute('transform', 'translate($newX, $newY)');
    }
  }
  
  void moveCompleted(MouseEvent e) {
    e.preventDefault();
    onMouseUpListener.cancel();
    onMouseMoveListener.cancel();
    onMouseLeaveListener.cancel();
    dragging = false;
  }
  
  dynamic getMouseCoordinates(e) {
    return {
      'x': (e.offset.x - canvas.currentTranslate.x) / canvas.currentScale, 
      'y': (e.offset.y - canvas.currentTranslate.y) / canvas.currentScale
    };
  }
}

class Application {
  /*
   * Constants
   */
  int WIDTH = 80, HEIGHT = 60;
  
  /*
   * Class variables
   */
  SvgSvgElement canvas;
  
  Application(canvas_id) {
    canvas = querySelector(canvas_id);
    canvas.onDoubleClick.listen(addNewUnit);
  }
  
  void addNewUnit(MouseEvent e) {
    num x = e.offset.x - WIDTH/2;
    num y = e.offset.y - HEIGHT/2;
    BasicUnit newUnit = new BasicUnit(this.canvas, x, y, WIDTH, HEIGHT);
    canvas.append(newUnit.group);
  }
}

void main() {
  Application app = new Application("#app_container");
}