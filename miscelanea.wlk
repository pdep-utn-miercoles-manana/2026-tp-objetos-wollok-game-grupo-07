import wollok.game.*
import powerUps.*
import personajes.*
import clases.*

class IndicadorHud {
    const property position
    const textoQueMuestra   // un bloque que devuelve el texto

    method text() = textoQueMuestra.apply()
    method textColor() = "000000FF"
}

const hudNivel = new IndicadorHud(position = game.at(0, 8), textoQueMuestra = { "Nivel: " + hud.nivelActual() })
const hudTiempo = new IndicadorHud(position = game.at(2, 8), textoQueMuestra = { "Tiempo: " + cronometro.segundos() })
const hudPuntaje = new IndicadorHud(position = game.at(7, 8), textoQueMuestra = { "Puntaje: " + puntaje.total() })

// OBJETOS, HAY 1 SOLO
object hud {
    var nivelActual = 1

    method nivelActual() = nivelActual
    method nivelActual(n) { nivelActual = n }

    method position() = game.at(1, 0)
    method text() = "Nivel: " + nivelActual + "Tiempo: " + cronometro.segundos() + "  Puntaje: " + puntaje.total()
    method textColor() = "000000FF"  //negro
  
}

object cronometro {
  var property segundos = 30

  method tick() { segundos = segundos - 1 }
  method seTerminoElTiempo() = segundos <= 0
  method agregarTiempo(tiempoExtra){
    segundos += tiempoExtra
  }
    method reiniciar(tiempoInicial) {segundos = tiempoInicial}
  
}

object puntaje {
  var property total = 0
  var multiplicar = false
  
  method sumar(puntos) { 
    if(multiplicar){
      total +=  puntos * 2
    } else {
      total +=  puntos
    }
  }

  method activarMultiplicador(){
    multiplicar = true
  }
  method desactivarMultiplicador(){
    multiplicar = false
  }

  method reiniciar() {
    total = 0
    multiplicar = false
  }
  
}

object mapa {
  const filasDePiso = [0, 1, 2, 4, 6]       
  const columnasDeEscalera = [0, 8]
  
  method esTransitable(posicion) {
    const estaEnElMapa = posicion.x() >= 0 && posicion.x() <= 8 && posicion.y() >= 0 && posicion.y() <= 6 // se me fue para afuera
    const enPisoOEscalera = filasDePiso.contains(posicion.y()) || columnasDeEscalera.contains(posicion.x())
    return estaEnElMapa && enPisoOEscalera
  }
}

object musica {
    method activar() {
        const fondo = game.sound("assets/musica_fondo.wav")
        fondo.shouldLoop(true)
        fondo.volume(0.1)
        game.schedule(500, { fondo.play() })
        keyboard.m().onPressDo({ fondo.volume(0) })
    }
}

object fondoHotel {
    method position() = game.at(0, 0)
    method image() = "assets/fondo_hotel.png"
}

class TextoVisual {
    const property text
    const property position
    method textColor() = "000000FF"
}

class Menu {
    const opciones
    var opcionSeleccionada = 0
    const titulo

    method iniciar() {
        nivel1.siguiente(nivel2)
        nivel2.siguiente(nivel3)

        game.clear()
        musica.activar()
        opcionSeleccionada = 0
        self.actualizarSeleccion()
        game.addVisual(new TextoVisual(text = titulo, position = game.at(3, 7)))
        opciones.forEach({ o => game.addVisual(o) })

        keyboard.up().onPressDo({ self.subir() })
        keyboard.down().onPressDo({ self.bajar() })
        keyboard.enter().onPressDo({ opciones.get(opcionSeleccionada).elegir() })
    }

    method subir() {
        opcionSeleccionada = [opcionSeleccionada - 1, 0].max()
        self.actualizarSeleccion()
    }

    method bajar() {
        opcionSeleccionada = [opcionSeleccionada + 1, opciones.size() - 1].min()
        self.actualizarSeleccion()
    }

    method actualizarSeleccion() {
        opciones.forEach({ o => o.seleccionada(false) })
        opciones.get(opcionSeleccionada).seleccionada(true)
    }
}

const menuPrincipal = new Menu(opciones = [
    new OpcionMenu(nombre = "Iniciar", position = game.at(3, 5), accion = { nivel1.iniciar() }),
    new OpcionMenu(nombre = "Niveles", position = game.at(3, 4), accion = { selectorNiveles.iniciar() })
], titulo = "MENU PRINCIPAL")

const selectorNiveles = new Menu(opciones = [
    new OpcionMenu(nombre = "Nivel 1", position = game.at(3, 6), accion = { nivel1.iniciar() }),
    new OpcionMenu(nombre = "Nivel 2", position = game.at(3, 5), accion = { nivel2.iniciar() }),
    new OpcionMenu(nombre = "Nivel 3", position = game.at(3, 4), accion = { nivel3.iniciar() }),
    new OpcionMenu(nombre = "Volver", position = game.at(3, 3), accion = { menuPrincipal.iniciar() })
], titulo = "SELECTOR DE NIVELES")