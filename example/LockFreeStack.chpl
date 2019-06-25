/*
  Created by Garvit Dewan - 
    https://github.com/dgarvit/epoch-based-manager/blob/bb31087532c808f21d11a07fcca5a30b17214559/src/LockFreeStack.chpl

  Lock-Free Stack that uses ABA feature of Distributed Data Structures
*/
  
module LockFreeStack {

  use LocalAtomics;

  class node {
    type eltType;
    var val : eltType;
    var next : unmanaged node(eltType);

    proc init(val : ?eltType) {
      this.eltType = eltType;
      this.val = val;
      next = nil;
    }
  }

  class LockFreeStack {
    type objType;
    var _top : LocalAtomicObject(unmanaged node(objType));

    proc init(type objType) {
      this.objType = objType;
    }

    proc push(newObj : objType) {
      var n = new unmanaged node(newObj);
      do {
        var oldTop = _top.readABA();
        n.next = oldTop.getObject();
      } while (!_top.compareExchangeABA(oldTop, n));
    }

    proc pop() : objType {
      var oldTop : ABA(unmanaged node(objType));
      do {
        oldTop = _top.readABA();
        if (oldTop.getObject() == nil) then
          return nil;
        var newTop = oldTop.next;
      } while (!_top.compareExchangeABA(oldTop, newTop));
      return oldTop.getObject();
    }

    proc top() : objType {
      return _top.read().val;
    }

    iter these() : objType {
      var head = _top.read();
      while (head != nil) {
        var next = head.next;
        yield head.val;
        head = next;
      }
    }

    proc deinit() {
      var head = _top.read();
      while (head != nil) {
        var next = head.next;
        delete head;
        head = next;
      }
    }
  }

  
  proc main() {
    var a = new LockFreeStack(int);
    coforall loc in Locales do on loc {
      forall i in here.id * 1024 .. #1024 do a.push(i);
    }
    writeln(+ reduce a);
  }
}
