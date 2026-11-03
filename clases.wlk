import wollok.game.*
import miscelanea.*
import personajes.*
import powerUps.*

// CLASES 
class Puerta {
    var property position
    var property abierta = false
    const piso

    method image() {
    if (abierta) 
      return "assets/puertanuevahombre.png"
    else 
      return "assets/puertanueva.png"
    }

    method abrir() {
        abierta = true
        const s = game.sound("assets/puerta_abrir.wav")
        s.volume(0.1)
        s.play()
    }

    method cerrar() {
        abierta = false
        const s = game.sound("assets/puerta_cerrar.wav")
        s.volume(0.1)
        s.play()
    }

    method puntos() = piso * 10  // piso 1 = 10pts, piso 2 = 20pts, piso 3 = 30pts
    method tiempoDado() = 10 - (piso * 3)  // piso1=7seg, piso2=4seg, piso3=1seg

    method agarrarBolsa(){
      abierta = false
    }

    method reiniciar() {
        self.cerrar()
    }
}   

const puerta1 = new Puerta(position = game.at(2, 2), piso = 1)
const puerta2 = new Puerta(position = game.at(4, 2), piso = 1)  
const puerta3 = new Puerta(position = game.at(6, 2), piso = 1)
const puerta4 = new Puerta(position = game.at(2, 4), piso = 2)
const puerta5 = new Puerta(position = game.at(4, 4), piso = 2)  
const puerta6 = new Puerta(position = game.at(6, 4), piso = 2)
const puerta7 = new Puerta(position = game.at(2, 6), piso = 3)
const puerta8 = new Puerta(position = game.at(4, 6), piso = 3)  
const puerta9 = new Puerta(position = game.at(6, 6), piso = 3)

const puertas = [puerta1, puerta2, puerta3, puerta4, puerta5, puerta6, puerta7, puerta8, puerta9]

class Nivel {
    const numero
    var property siguiente = null
    const tiempoAbrirPuertas
    const tiempoCerrarPuertas
    const tiempoAparicionPowerUp
    const tiempo
    const puntosParaGanar
    const tiempoValla

    method iniciar() {
        game.clear()
        cronometro.reiniciar(tiempo)
        jugador.reiniciar()
        puntaje.reiniciar()
        puertas.forEach({puerta => puerta.reiniciar()})
        powerUpsRevisar.reiniciar()
        hud.nivelActual(numero)
        hud.puntosParaGanar(puntosParaGanar)

        game.addVisual(fondoHotel)
        puertas.forEach({ puerta => game.addVisual(puerta) }) // agregar visual de las puertas


        game.onTick(tiempoAbrirPuertas, "abrirPuertas", {
            const cerradas = puertas.filter({ puerta => !puerta.abierta() })
            if (cerradas.size() > 0) {
                const elegida = cerradas.get((0).randomUpTo(cerradas.size()).truncate(0))
                elegida.abrir()
            }
        })
        
        if (tiempoValla != null) {
        game.schedule(tiempoValla, { self.activarValla(tiempoValla) })
        }

        game.onTick(tiempoCerrarPuertas,"cerrarPuertas", 
            {puertas.filter({ puerta => puerta.abierta() }).forEach({ puerta => puerta.cerrar() }) // de las puertas cerrarlas cada 10seg (hay q probarla ni idea)
            }) // CADA 10 SEGUNDOS CERRALAS

        game.addVisual(jugador)
        game.addVisual(camionRecolector)

        keyboard.right().onPressDo({ jugador.moverDerecha() }) // movmiento
        keyboard.left().onPressDo({ jugador.moverIzquierda() })
        keyboard.up().onPressDo({ jugador.moverArriba() })
        keyboard.down().onPressDo({ jugador.moverAbajo() })

        keyboard.space().onPressDo({
            if (jugador.tieneBolsa()) {
                if (jugador.position() == camionRecolector.position() || 
                    jugador.position() == game.at(camionRecolector.position().x() + 1, camionRecolector.position().y()) ||
                    jugador.position() == game.at(camionRecolector.position().x(), camionRecolector.position().y() + 1)) {
                    camionRecolector.agarrarBolsa()
                    jugador.soltar()
                    if (puntaje.total() >= puntosParaGanar) {
                        self.ganar()
                    }
                }
            } else {
                const puertaAbierta = puertas.findOrElse(
                    { p => p.abierta() && p.position() == jugador.position() },
                    { null } // raro
                )
                if (puertaAbierta != null) {
                    puertaAbierta.agarrarBolsa()
                    jugador.agarrar(puertaAbierta)
                }
            }
        })

        keyboard.r().onPressDo({ self.iniciar() })
        keyboard.q().onPressDo({ menuPrincipalImagen.iniciar() })

        game.addVisual(valla)
        game.addVisual(hudNivel)
        game.addVisual(hudTiempo)
        game.addVisual(hudPuntaje)
        game.addVisual(hudPuntosParaGanar)
        game.onTick(1000,"actualizarCronometro", {
            cronometro.tick()
            if (cronometro.seTerminoElTiempo()) { self.perder() }
        }) // cada 1 segundo baja el tiempo del hud

        powerUpsRevisar.iniciar()
        game.onTick(tiempoAparicionPowerUp, "aparecerPowerUp", { powerUpsRevisar.hacerAparecer() })
    }

    method ganar() {
    pantallaGanar.iniciar(self)
    }

    method perder() {
        pantallaPerder.iniciar(self)
    }

    method activarValla(tiempoo) {
    valla.activar()
    game.schedule(tiempoo, {
        valla.desactivar()
        game.schedule(tiempoo, { self.activarValla(tiempoo) })
    })
}
}

const nivel1 = new Nivel(numero = 1, tiempo = 60, tiempoAbrirPuertas = 2000, tiempoCerrarPuertas = 12000, tiempoAparicionPowerUp = 5000, puntosParaGanar = 100, tiempoValla = null)
const nivel2 = new Nivel(numero = 2, tiempo = 55, tiempoAbrirPuertas = 2500, tiempoCerrarPuertas = 10000, tiempoAparicionPowerUp = 6000, puntosParaGanar = 150, tiempoValla = null)
const nivel3 = new Nivel(numero = 3, tiempo = 50, tiempoAbrirPuertas = 3000, tiempoCerrarPuertas = 8000,  tiempoAparicionPowerUp = 7000, puntosParaGanar = 200, tiempoValla = 8000)
const nivel4 = new Nivel(numero = 4, tiempo = 45, tiempoAbrirPuertas = 3500, tiempoCerrarPuertas = 6000,  tiempoAparicionPowerUp = 8000, puntosParaGanar = 250, tiempoValla = 6000)
const nivel5 = new Nivel(numero = 5, tiempo = 40, tiempoAbrirPuertas = 4000, tiempoCerrarPuertas = 4000,  tiempoAparicionPowerUp = 9000, puntosParaGanar = 300, tiempoValla = 4000)