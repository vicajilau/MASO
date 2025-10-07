## Diagramas de estado

En esta sección se presentan los diagramas de estado que definen el comportamiento de los procesos dentro del simulador MASO, en función del algoritmo de planificación seleccionado. Cada algoritmo se describe como un autómata de estados finito en el que las transiciones dependen de eventos como: llegada de procesos/hilos, inicio y finalización de ráfagas (CPU / I/O), preempción, expiración de quantum y cambios de contexto.

Se incluyen:

- Estados comunes: Ready (listo), Running (ejecutando), Waiting (bloqueado en I/O), ContextSwitch (cambio de contexto), Idle (CPU libre), Finished (finalizado).
- Eventos: arrival (llegada de proceso/hilo), start_cpu, finish_cpu, start_io, finish_io, preempt, quantum_expire, context_switch_start, context_switch_end.

Nota: los algoritmos implementados en MASO cubren variantes no preemptivas (FIFO, SJF, Priority, Multiple Priority Queues, MPQ con feedback - por slices) y preemptivas (SRTF, Round Robin, Time Limit). Para procesos tipo "burst" (con hilos y ráfagas CPU/I/O) se emplean colas separadas para CPU e I/O y estados equivalentes por hilo.

### Interfaz (inputs / outputs / criterios)

Esta subsección define de forma concisa la interfaz del servicio de planificación: qué datos requiere (inputs), qué produce (outputs) y qué criterios se usan para considerar que la ejecución es correcta. Se usa como contrato técnico para facilitar revisiones, pruebas automatizadas y para dejar explícitos los supuestos que deben cumplirse antes de ejecutar los algoritmos en MASO.

- Inputs: lista de procesos (RegularProcess o BurstProcess), `ExecutionSetup` (nº CPUs, nº canales I/O, quantum, timeLimit, contextSwitchTime, modo de procesos).
- Output: estructura `Machine` con la línea de tiempo de cada CPU e I/O (componentes `HardwareComponent` con estados: free, busy, switchingContext).
- Criterio de éxito: el diagrama y descripción permiten reconstruir el comportamiento observando las transiciones principales implementadas en las clases de servicio.

### Estados y semántica

- Idle / Free: la CPU o canal I/O no tiene trabajo. En el código se representa con `HardwareState.free` y se modela como ráfagas ficticias `freeProcess`.
- Busy / Running: ejecución de una ráfaga de CPU o I/O por un proceso/hilo (`HardwareState.busy`).
- ContextSwitch / SwitchingContext: periodo de cambio de contexto entre procesos (`HardwareState.switchingContext`).
- Ready: proceso/hilo está en cola listo para ejecutarse (no se materializa directamente en `HardwareComponent`, pero sí en las colas internas como `readyQueue`, `cpuReadyQueue`, etc.).
- Waiting: proceso/hilo se encuentra en espera de I/O; modelado por su presencia en la cola de I/O o por estar en `ioChannels` ocupados.
- Finished: proceso/hilo que ya completó todas sus ráfagas.

### Eventos principales

- arrival: un proceso o hilo entra en sistema. Mueve de no-existente -> Ready.
- start_cpu: el planificador asigna la ráfaga CPU a una CPU -> Ready -> Running.
- finish_cpu: la ráfaga CPU termina -> Running -> Waiting (si sigue con I/O) o -> Finished.
- start_io / finish_io: analógico para ráfagas I/O -> Waiting -> Running(io) -> Ready/Finished.
- preempt: (SRTF, RR con quantum, TimeLimit) evento que desplaza la ejecución actual -> Running -> Ready (posible ContextSwitch en medio).
- quantum_expire / time_limit_expire: el slice se acaba -> Running -> Ready (o democión en MPQ Feedback).
- context_switch_start / context_switch_end: periodo de cambio de contexto -> Running -> ContextSwitch -> Running (otro proceso) o Idle.

---

## Diagramas por algoritmo (PlantUML)

Nota: los diagramas se presentan en Bloque PlantUML listo para pegar en cualquier herramienta que soporte PlantUML (sitio web de PlantUML, extensiones VSCode, etc.) y exportar a imagen.

En multi-CPU cada CPU sigue un autómata equivalente; la diferencia está en la política de asignación (asignación cíclica simple para FIFO de procesos regulares, asignación a CPUs libres por disponibilidad para sistemas con colas de ráfagas, selección por CPU con menor carga, etc.).

---

### 1) FIFO (First-In, First-Out)

Descripción corta: no preemptivo. Procesos ordenados por llegada; para procesos regulares la implementación asigna cada proceso a la siguiente CPU en la secuencia (rotación). Para burst se usa una cola FIFO de ráfagas y se asigna a CPUs libres según disponibilidad.

```plantuml
@startuml FIFO
title FIFO (regular processes)
state Arrival
state Ready
state Running
state Finished
Arrival --> Ready : arrival
Ready --> Running : start_cpu
Running --> Finished : finish_cpu
@enduml
```

---

### 2) SJF (Shortest Job First) - no preemptivo

Descripción corta: selecciona la tarea con menor serviceTime entre las que han llegado. No preemptivo.

PlantUML:

```plantuml
@startuml SJF
title SJF (non-preemptive)
state Ready
state Running
Ready --> Running : select shortest / start_cpu
Running --> Ready : finish_cpu
@enduml
```

---

### 3) SRTF (Shortest Remaining Time First) - preemptivo

Descripción corta: preemptivo por tiempo restante. Si llega una tarea con menor tiempo restante, se preempe la actual.

PlantUML:

```plantuml
@startuml SRTF
title SRTF (preemptive)
state Ready
state Running
Ready --> Running : start_cpu
Running --> Ready : preempt
Running --> Finished : finish_cpu
@enduml
```

---

### 4) Round Robin (RR)

Descripción corta: preemptivo por quantum. Cada proceso obtiene un slice; si no finaliza se reencola.

PlantUML:

```plantuml
@startuml RR
title Round Robin
state Ready
state Running
Ready --> Running : start_cpu
Running --> Ready : quantum_expire
Running --> Finished : finish_cpu
@enduml
```

---

### 5) Time Limit

Descripción corta: similar a RR pero el límite por turno es `timeLimit`.

PlantUML:

```plantuml
@startuml TimeLimit
title Time Limit
state Ready
state Running
Ready --> Running : start_cpu
Running --> Ready : time_limit_expire
Running --> Finished : finish_cpu
@enduml
```

---

### 6) Priority (no preemptivo - según implementación)

Descripción corta: los procesos se ordenan por `priority` (valor menor = mayor prioridad) y luego por arrival time. Asignación cíclica para procesos regulares.

PlantUML:

```plantuml
@startuml Priority
title Priority (non-preemptive)
state Ready
state Running
Ready --> Running : select by priority / start_cpu
Running --> Finished : finish_cpu
@enduml
```

---

### 7) Multiple Priority Queues (MPQ) - no preemptivo

Descripción corta: colas por prioridad procesadas de mayor a menor; FIFO dentro de cada cola.

PlantUML:

```plantuml
@startuml MPQ
title Multiple Priority Queues
state MPQ
state Running
MPQ --> Running : dequeue from highest non-empty queue
Running --> Finished : finish_cpu
@enduml
```

---

### 8) Multiple Priority Queues with Feedback (MPQ Feedback)

Descripción corta: múltiples niveles con democión al consumir todo el quantum; cada nivel puede tener su quantum.

PlantUML:

```plantuml
@startuml MPQFeedback
title MPQ with Feedback
state Ready
state Running
Ready --> Running : start_cpu
Running --> Ready : quantum_expire / demote
Running --> Finished : finish_cpu
@enduml
```

---