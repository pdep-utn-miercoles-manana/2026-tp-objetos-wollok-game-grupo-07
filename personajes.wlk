import wollok.game.*
import miscelanea.*
import powerUps.*

object camionRecolector {
  var property position = game.at(4,0)

  method image() = "assets/camionBasura.png"

  method agarrarBolsa() {
  if (jugador.deQuePuertaEsBolsa() != null) {
      puntaje.sumar(jugador.deQuePuertaEsBolsa().puntos())
    
      const s = game.sound("assets/dejarbolsa.wav")
      s.volume(0.1)
      s.play()
    }
 }
}

object jugador {
    var property position = game.at(4, 2) // posicion inicial
    var property tieneBolsa = false
    var property deQuePuertaEsBolsa = null
    var direccion = "frontal" // puede ser frontal derecha o izquierda
    var property controlesInvertidos = false

    method image() {
    if(direccion == "derecha") {
      if (tieneBolsa) return "assets/crashdeladoderechabolsa.png"
      else return "assets/crashdeladoderecha.png"
    } 
    else if(direccion == "izquierda") {
      if (tieneBolsa) return "assets/crashdeladobolsa.png"
      else return "assets/crashdelado.png"
    } 
    else if (tieneBolsa) return "assets/crashfrontalbolsa.png"
    else return "assets/frontalpersonaje.png"
  }
    
    method intentarMover(posicionNueva){
      if(mapa.esTransitable(posicionNueva)){
        position = posicionNueva
        powerUpsRevisar.revisarColision(self)
      }
    }

    method moverDerecha(){
      if (controlesInvertidos) {
        direccion = "izquierda"
        self.intentarMover(position.left(1))
      } else {
        direccion = "derecha"
        self.intentarMover(position.right(1))
      }
    }

    method moverIzquierda(){
      if (controlesInvertidos) {
        direccion = "derecha"
        self.intentarMover(position.right(1))
      } else {
        direccion = "izquierda"
        self.intentarMover(position.left(1))
      }
    }

    method moverArriba(){
      direccion = "frontal"
      if (controlesInvertidos) self.intentarMover(position.down(1))
      else self.intentarMover(position.up(1))
    }

    method moverAbajo(){
      direccion = "frontal"
      if (controlesInvertidos) self.intentarMover(position.up(1))
      else self.intentarMover(position.down(1))
    }

    method activarControlesInvertidos() { controlesInvertidos = true }
    method desactivarControlesInvertidos() { controlesInvertidos = false } 

    method agarrar(puerta){ 
      tieneBolsa = true
      deQuePuertaEsBolsa = puerta
    }

    method soltar(){
      tieneBolsa = false
      deQuePuertaEsBolsa = null
    }

    method reiniciar() {
        position = game.at(4, 2)
        self.soltar()
        direccion = "frontal"
        controlesInvertidos = false
    }
}