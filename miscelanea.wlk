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
const hudPuntaje = new IndicadorHud(position = game.at(8, 8), textoQueMuestra = { "Puntaje: " + puntaje.total() })
const hudPuntosParaGanar = new IndicadorHud(position = game.at(6, 8), textoQueMuestra = { "Meta: " + hud.puntosParaGanar() })

// OBJETOS, HAY 1 SOLO
object hud {
    var nivelActual = 1
    var puntosParaGanar = 0


    method puntosParaGanar() = puntosParaGanar
    method puntosParaGanar(n) { puntosParaGanar = n }
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
    return estaEnElMapa && enPisoOEscalera && valla.esTransitable(posicion)
  }
}

object musica {
    var sonando = false
    const fondo = game.sound("assets/musica_menu.wav")

    method activar() {
        if (!sonando) {
            
            fondo.volume(0.02)
            fondo.play()
            sonando = true
            keyboard.m().onPressDo({ fondo.volume(0) })
        }
    }

    method detener() {
        sonando = false // NO FRENA NUNCA XD
        fondo.stop()
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
        if (opcionSeleccionada == 0) return "assets/menu_principal1.png"
        else if (opcionSeleccionada == 1) return "assets/menu_principal2.png"
        else return "assets/menu_principal3.png"
    }

    method iniciar() {
        nivel1.siguiente(nivel2)
        nivel2.siguiente(nivel3)

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
        opcionSeleccionada = [opcionSeleccionada + 1, 2].min()
    }

    method elegir() {
        if (opcionSeleccionada == 0) nivel1.iniciar()
        else if (opcionSeleccionada == 1) selectorNiveles.iniciar()
        else creditos.iniciar()
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

object pantallaGanar {
    var opcionSeleccionada = 0
    var nivelActual = null
    

    method tieneSiguiente() = nivelActual != null && nivelActual.siguiente() != null

    method cantOpciones() = if (self.tieneSiguiente()) 2 else 1

    method position() = game.at(0, 0)

    method image() {
        if (self.tieneSiguiente()) {
            if (opcionSeleccionada == 0) return "assets/nivel_completado1.png"
            else if (opcionSeleccionada == 1) return "assets/nivel_completado2.png"
            else return "assets/nivel_completado3.png"
        } else {
            if (opcionSeleccionada == 0) return "assets/nivel_completado2.png"
            else return "assets/nivel_completado3.png"
        }
    }

    method iniciar(unNivel) {
        nivelActual = unNivel
        opcionSeleccionada = 0
        game.clear()
        const s = game.sound("assets/sonido_ganar.wav")
        s.volume(0.1)
        s.play()
        game.addVisual(self)
        keyboard.up().onPressDo({ self.subir() })
        keyboard.down().onPressDo({ self.bajar() })
        keyboard.enter().onPressDo({ self.elegir() })
    }

    method subir() {
        opcionSeleccionada = [opcionSeleccionada - 1, 0].max()
    }

    method bajar() {
        opcionSeleccionada = [opcionSeleccionada + 1, self.cantOpciones()].min()
    }

    method elegir() {
        if (self.tieneSiguiente()) {
            if (opcionSeleccionada == 0) nivelActual.siguiente().iniciar()
            else if (opcionSeleccionada == 1) nivelActual.iniciar()
            else menuPrincipalImagen.iniciar()
        } else {
            if (opcionSeleccionada == 0) nivelActual.iniciar()
            else menuPrincipalImagen.iniciar()
        }
    }
}

object pantallaPerder {
    var opcionSeleccionada = 0
    var nivelActual = null
    

    method position() = game.at(0, 0)

    method image() {
        if (opcionSeleccionada == 0) return "assets/nivel_perdido1.png"
        else return "assets/nivel_perdido2.png"
    }

    method iniciar(unNivel) {
        nivelActual = unNivel
        opcionSeleccionada = 0
        game.clear()
        const s = game.sound("assets/sonido_perder.wav")
        s.volume(0.1)
        s.play()
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
        if (opcionSeleccionada == 0) nivelActual.iniciar()
        else menuPrincipalImagen.iniciar()
    }
}

object intro {
    var imagenActual = 0
    const imagenes = [
        "assets/intro1.jpg",
        "assets/intro2.jpg",
        "assets/intro3.jpg",
        "assets/intro4.jpg",
        "assets/intro5.jpg"
    ]

    method position() = game.at(0, 0)

    method image() = imagenes.get(imagenActual)

    method iniciar() {
        imagenActual = 0
        game.clear()
        game.addVisual(self)
        keyboard.enter().onPressDo({ self.siguiente() })
    }

    method siguiente() {
        if (imagenActual < imagenes.size() - 1) {
            imagenActual += 1
        } else {
            menuPrincipalImagen.iniciar()
        }
    }
}

object creditos {
    method position() = game.at(0, 0)
    method image() = "assets/creditos.jpg"

    method iniciar() {
        game.clear()
        game.addVisual(self)
        keyboard.enter().onPressDo({ menuPrincipalImagen.iniciar() })
    }
}

object valla {
    var property position = game.at(11, 8)  // escondida por defecto
    var property activa = false

    method image() = "assets/valla.png"

    method activar() {
        const escaleras = [0, 8]
        const x = escaleras.get((0).randomUpTo(2).truncate(0))
        const y = (1).randomUpTo(6).truncate(0)
        position = game.at(x, y)
        activa = true
    }

    method desactivar() {
        position = game.at(11, 8)
        activa = false
    }

    method esTransitable(pos) = !(activa && pos == position)
}
