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

    method abrir(){
        abierta = true
        //const volAbrir = game.sound("assets/puerta_abrir.wav").play()
        //volAbrir.volume(0.01)
        
    }
      // POR ALGUN MOTIVO CUANDO PONGO VOLUMEN NO FUNCIONA EL MECANISMO DE ABRIR Y CERRAR PUERTAS BIEN
    method cerrar() {
        abierta = false
        //const volCerrar = game.sound("assets/puerta_cerrar.wav").play()
        //volCerrar.volume(0.01)
        
        
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

    method iniciar() {
        game.clear()
        musica.activar()
        cronometro.reiniciar(tiempo)
        jugador.reiniciar()
        puntaje.reiniciar()
        puertas.forEach({puerta => puerta.reiniciar()})
        powerUpsRevisar.reiniciar()
        hud.nivelActual(numero)

        game.addVisual(fondoHotel)
        puertas.forEach({ puerta => game.addVisual(puerta) }) // agregar visual de las puertas


        game.onTick(tiempoAbrirPuertas, "abrirPuertas", {
            const cerradas = puertas.filter({ puerta => !puerta.abierta() })
            if (cerradas.size() > 0) {
                const elegida = cerradas.get((0).randomUpTo(cerradas.size()).truncate(0))
                elegida.abrir()
            }
        })


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
                if (jugador.position() == camionRecolector.position()) {
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

        game.addVisual(hudNivel)
        game.addVisual(hudTiempo)
        game.addVisual(hudPuntaje)
        game.onTick(1000,"actualizarCronometro", {
            cronometro.tick()
            if (cronometro.seTerminoElTiempo()) { self.perder() }
        }) // cada 1 segundo baja el tiempo del hud

        powerUpsRevisar.iniciar()
        game.onTick(tiempoAparicionPowerUp, "aparecerPowerUp", { powerUpsRevisar.hacerAparecer() })
    }

    method opcionReiniciar(fila) =
        new OpcionMenu(nombre = "Reiniciar nivel", position = game.at(3, fila), accion = { self.iniciar() })

    method opcionVolverAlMenu(fila) =
        new OpcionMenu(nombre = "Volver al menu principal", position = game.at(3, fila), accion = { menuPrincipalImagen.iniciar() })


    method ganar() {
        const opciones = []
        if (siguiente != null) {
            opciones.add(new OpcionMenu(nombre = "Siguiente nivel", position = game.at(3, 6), accion = { siguiente.iniciar() }))
        }
        opciones.add(self.opcionReiniciar(5))
        opciones.add(self.opcionVolverAlMenu(4))
        new Menu(titulo = "¡Ganaste! :D", opciones = opciones).iniciar()
    }

    method perder() {
        new Menu(titulo = "Perdiste :(", opciones = [self.opcionReiniciar(5), self.opcionVolverAlMenu(4)]).iniciar()
    }
}

const nivel1 = new Nivel(numero = 1, tiempo = 50, tiempoAbrirPuertas = 3000, tiempoCerrarPuertas = 10000, tiempoAparicionPowerUp = 5000, puntosParaGanar = 25)
const nivel2 = new Nivel(numero = 2, tiempo = 45, tiempoAbrirPuertas = 3500, tiempoCerrarPuertas = 7000, tiempoAparicionPowerUp = 6000, puntosParaGanar = 30)
const nivel3 = new Nivel(numero = 3, tiempo = 40, tiempoAbrirPuertas = 4000, tiempoCerrarPuertas = 5000, tiempoAparicionPowerUp = 7000, puntosParaGanar = 35)
const nivel4 = new Nivel(numero = 4, tiempo = 35, tiempoAbrirPuertas = 4500, tiempoCerrarPuertas = 3500, tiempoAparicionPowerUp = 7000, puntosParaGanar = 30)
const nivel5 = new Nivel(numero = 5, tiempo = 30, tiempoAbrirPuertas = 4500, tiempoCerrarPuertas = 3500, tiempoAparicionPowerUp = 7000, puntosParaGanar = 30)

class OpcionMenu {
    const property nombre
    const property position
    var property seleccionada = false
    const accion

    method text() {
        if (seleccionada) {
            return "> " + nombre
        }
        else {
            return " " + nombre
        }
    }
    method textColor() = "000000FF"
    
    method elegir() { accion.apply() }
}