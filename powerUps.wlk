import wollok.game.*
import personajes.*
import miscelanea.*

object powerUpTeletransporte {
  var property position = game.at(0,0)
  method image() = "assets/powerupteletransporte.png" 

  method aplicar(unJugador){
    unJugador.position(camionRecolector.position())
  }
}

object powerUpMultiplicador {
  var property position = game.at(0,0)

  method image() = "assets/powerupmultiplicador.png"

  method aplicar(unJugador){
    puntaje.activarMultiplicador()
    game.schedule(10000, {puntaje.desactivarMultiplicador()})
  }
}

object powerUpCascaraDeBanana {
  var property position = game.at(0,0)
  method image() = "assets/powerupbanana.png"

  method aplicar(unJugador){
    unJugador.soltar()
  }
}

object powerUpRelojRoto {
  var property position = game.at(0,0)
  method image() = "assets/poweruprelojroto.png"

  method aplicar(unJugador){
    cronometro.agregarTiempo(-5)
  }
}

object powerUpRelojBueno {
  var property position = game.at(0,0)
  method image() = "assets/poweruprelojroto.png"

  method aplicar(unJugador){
    cronometro.agregarTiempo(5)
    
  }
}

object powerUpControlesInvertidos {
  var property position = game.at(0,0)
  method image() = "assets/puertanuevahombre.png" // provisional

  method aplicar(unJugador){
    unJugador.activarControlesInvertidos()
    game.schedule(5000, { unJugador.desactivarControlesInvertidos() })
  }
}

object powerUpsRevisar {
  const powerUps = [powerUpTeletransporte, powerUpMultiplicador, powerUpCascaraDeBanana, powerUpRelojRoto, powerUpRelojBueno, powerUpControlesInvertidos]
  
  var property activoAhora = null
  const posicionEscondida = game.at(11, 8)

  method iniciar() {
    powerUps.forEach({ power => 
      power.position(posicionEscondida)
      game.addVisual(power)
    })
  }

  method hacerAparecer(){
    self.ocultar()

    activoAhora = powerUps.get((0).randomUpTo(powerUps.size()).truncate(0))
    const escaleras = [0, 8]
    const escaleraElegida = escaleras.get((0).randomUpTo(escaleras.size()).truncate(0))
    activoAhora.position(game.at(escaleraElegida, (0).randomUpTo(6).truncate(0)))
    //const aparecer = game.sound("assets/powerupaparecer.wav").play()
    //aparecer.volume(0.1)
    game.schedule(5000, { self.ocultar() })
  }

  method ocultar() {
    if (activoAhora != null) {
      activoAhora.position(posicionEscondida)
      activoAhora = null
    }
  }

  method revisarColision(jugador) {
    if (activoAhora != null && activoAhora.position() == jugador.position()) {
      activoAhora.aplicar(jugador)
      //const agarrar = game.sound("assets/powerupagarrar.wav").play()
      //agarrar.volume(0.1)
      self.ocultar()
    }
  }

  method reiniciar() {
        activoAhora = null
    }
}