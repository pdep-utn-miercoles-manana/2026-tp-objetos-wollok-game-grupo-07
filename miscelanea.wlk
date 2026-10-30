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


object menuPrincipalImagen {
    var opcionSeleccionada = 0

    method position() = game.at(0, 0)

    method image() {
        if (opcionSeleccionada == 0)
            return "assets/menu_principal1.png"
        else
            return "assets/menu_principal2.png"
    }

    method iniciar() {
        nivel1.siguiente(nivel2)
        nivel2.siguiente(nivel3)

        game.clear()
        musica.activar()
        opcionSeleccionada = 0

        game.addVisual(self)

        keyboard.up().onPressDo({ self.subir() })
        keyboard.down().onPressDo({ self.bajar() })
        keyboard.enter().onPressDo({ self.elegir() })
    }

    method subir() {
        opcionSeleccionada = [opcionSeleccionada - 1, 0].max()
    }

    method bajar() {
        opcionSeleccionada = [opcionSeleccionada + 1, 1].min()
    }

    method elegir() {
        if (opcionSeleccionada == 0)
            nivel1.iniciar()
        else
            selectorNiveles.iniciar()
    }
}

object selectorNiveles {
    var opcionSeleccionada = 0
    // 0=nivel1, 1=nivel2, 2=nivel3, 3=nivel4, 4=nivel5, 5=volver

    method position() = game.at(0, 0)

    method image() {
        if (opcionSeleccionada == 0) return "assets/selector_niveles1.png"
        else if (opcionSeleccionada == 1) return "assets/selector_niveles2.png"
        else if (opcionSeleccionada == 2) return "assets/selector_niveles3.png"
        else if (opcionSeleccionada == 3) return "assets/selector_niveles4.png"
        else if (opcionSeleccionada == 4) return "assets/selector_niveles5.png"
        else return "assets/selector_niveles6.jpg"
    }

    method iniciar() {
        game.clear()
        opcionSeleccionada = 0
        game.addVisual(self)
        keyboard.up().onPressDo({ self.subir() })
        keyboard.down().onPressDo({ self.bajar() })
        keyboard.enter().onPressDo({ self.elegir() })
    }

    method subir() {
        opcionSeleccionada = [opcionSeleccionada - 1, 0].max()
    }

    method bajar() {
        opcionSeleccionada = [opcionSeleccionada + 1, 5].min()
    }

    method elegir() {
        if (opcionSeleccionada == 0) nivel1.iniciar()
        else if (opcionSeleccionada == 1) nivel2.iniciar()
        else if (opcionSeleccionada == 2) nivel3.iniciar()
        else if (opcionSeleccionada == 3) nivel4.iniciar()
        else if (opcionSeleccionada == 4) nivel5.iniciar()
        else menuPrincipalImagen.iniciar()
    }
}

