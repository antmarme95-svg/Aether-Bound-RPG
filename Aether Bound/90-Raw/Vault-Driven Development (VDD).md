# **Vault-Driven Development (VDD)**

## **AI-Native Development Framework v1.0**

*"El conocimiento pertenece al proyecto, no al modelo de IA."*

---

# **Visión**

El desarrollo moderno asistido por IA suele depender de conversaciones.

El contexto vive dentro del chat.

Las decisiones importantes terminan enterradas entre cientos de mensajes.

Los prompts se vuelven cada vez más largos.

El modelo necesita que constantemente se le recuerde cómo funciona el proyecto.

Este enfoque no escala para videojuegos cuya vida útil puede extenderse durante varios años.

Vault-Driven Development (VDD) propone un paradigma diferente.

El conocimiento deja de vivir dentro de la conversación.

La conversación deja de ser la fuente de verdad.

Toda la inteligencia permanente vive dentro del Vault.

Claude Code únicamente consulta el Vault, interpreta el estado actual del proyecto y ejecuta el siguiente procedimiento operativo.

---

# **Objetivos**

El sistema busca:

* eliminar la dependencia de prompts largos  
* hacer que cualquier sesión pueda retomarse inmediatamente  
* mantener sincronizados código y documentación  
* separar conocimiento de ejecución  
* hacer reutilizables los procesos de desarrollo  
* permitir cambiar de modelo de IA sin perder el sistema  
* convertir el desarrollo en un proceso determinista

---

# **Filosofía**

Los prompts son efímeros.

Los Programming Loops son permanentes.

Los prompts desaparecen.

Los procesos evolucionan.

El verdadero activo del proyecto no es el código.

Tampoco los prompts.

Es el sistema capaz de producir ambos.

---

# **Principios Fundamentales**

## **1\. Single Source of Truth**

Toda la información permanente debe existir únicamente dentro del Vault.

Nunca dentro de conversaciones.

Nunca únicamente en memoria del modelo.

Nunca únicamente dentro del código.

---

## **2\. Determinismo**

Dos ejecuciones iguales deben producir resultados equivalentes.

Las decisiones importantes nunca deben depender del azar.

---

## **3\. Reproducibilidad**

Cualquier agente debe poder continuar el desarrollo leyendo únicamente el Vault.

---

## **4\. Evolución Continua**

El sistema mejora no solamente el videojuego.

También mejora la manera de construir videojuegos.

---

# **Arquitectura General**

                   VAULT

        Knowledge Layer  
               │  
               ▼  
         State Layer  
               │  
               ▼  
       Scheduler Engine  
               │  
               ▼  
     Programming Loop Engine  
               │  
               ▼  
     Multi-Agent Orchestrator  
               │  
               ▼  
     Specialized AI Agents  
               │  
               ▼  
     Código \+ Tests \+ Docs  
               │  
               ▼  
        Actualización  
           del Vault

Todo termina regresando al Vault.

---

# **El Vault**

El Vault representa el sistema operativo del proyecto.

No es un repositorio de notas.

Es un sistema vivo.

Contiene:

* conocimiento  
* estado  
* procesos  
* decisiones  
* backlog  
* estándares  
* arquitectura  
* producción  
* retrospectivas

---

# **Las Tres Capas**

## **Knowledge Layer**

Describe cómo funciona el videojuego.

Incluye:

* GDD  
* Lore  
* Economía  
* Mundo  
* Personajes  
* Mecánicas  
* Arquitectura  
* UI  
* Audio  
* Convenciones

Esta información cambia lentamente.

---

## **State Layer**

Describe únicamente dónde se encuentra el proyecto.

Nunca explica el diseño.

Explica el progreso.

Ejemplo:

Milestone

Sprint

Current Goal

Known Issues

Technical Debt

Current Feature

Blocked Tasks

Completed Features

Recent Decisions

Next Priority

Current Branch

Claude comienza siempre aquí.

---

## **Execution Layer**

Describe cómo trabajar.

No contiene conocimiento.

Contiene procedimientos.

Aquí viven los Programming Loops.

---

# **El Vault como Máquina de Estados**

Todo el desarrollo se modela como una State Machine.

Cada loop representa una transición.

Estado A

↓

Loop

↓

Estado B

Ejemplo

Movement Prototype

↓

Movement Loop

↓

Movement MVP

↓

Optimization Loop

↓

Optimized Movement

↓

Testing Loop

↓

Production Ready

Cada transición debe indicar:

Estado de entrada.

Condiciones necesarias.

Resultados esperados.

Estado de salida.

---

# **Scheduler**

No todos los loops pueden ejecutarse en cualquier momento.

Existe un Scheduler.

El Scheduler analiza:

Estado actual.

Dependencias.

Prioridad.

Bloqueos.

Milestone.

Roadmap.

Y determina qué loops son válidos.

Ejemplo

Estado actual

↓

Loops disponibles

↓

Priorización

↓

Loop seleccionado

Claude nunca debería ejecutar un loop inválido.

---

# **Programming Loops**

Los Programming Loops reemplazan los prompts.

Cada Loop representa un protocolo operativo.

Ejemplos

Feature Loop

Bug Loop

Optimization Loop

Combat Loop

Narrative Loop

UI Loop

Performance Loop

Testing Loop

Documentation Loop

Architecture Loop

Release Loop

Cada uno define exactamente cómo trabajar.

Nunca qué responder.

---

# **Contrato de un Programming Loop**

Cada Loop debe especificar:

Nombre

Objetivo

Estado de Entrada

Estado de Salida

Inputs

Outputs

Dependencias

Documentos requeridos

Validaciones

Rollback

Artefactos afectados

Siguiente Loop recomendado

Un Loop es un contrato.

No una conversación.

---

# **Estructura de un Loop**

## **Fase 1**

Leer Current State

---

## **Fase 2**

Leer documentación relevante

---

## **Fase 3**

Planear

Impacto

Riesgos

Archivos

Dependencias

---

## **Fase 4**

Implementar

---

## **Fase 5**

Validar

Compilación

Tests

Consistencia

---

## **Fase 6**

Actualizar

Código

Documentación

Backlog

ADR

Current State

---

## **Fase 7**

Finalizar

Notificar siguiente estado.

---

# **Multi-Agent Architecture**

El sistema no utiliza un único modelo.

Utiliza múltiples agentes especializados.

---

# **Orchestrator**

Existe un único Orchestrator.

Responsabilidades:

Leer el Vault.

Leer el estado.

Seleccionar el Loop.

Planificar.

Dividir el trabajo.

Elegir modelos.

Integrar resultados.

Actualizar el estado.

Nunca debe implementar todo por sí mismo.

Debe coordinar.

---

# **Selección Dinámica de Modelos**

Cada tarea debe utilizar el modelo más adecuado.

No siempre el más grande.

Factores:

Complejidad.

Costo.

Latencia.

Contexto.

Riesgo.

Disponibilidad.

Ejemplo

Arquitectura

→ modelo grande

Gameplay

→ modelo grande

Testing

→ modelo pequeño

Documentación

→ modelo pequeño

Comentarios

→ modelo pequeño

Linting

→ modelo pequeño

Formateo

→ modelo pequeño

---

# **Agentes Especializados**

Ejemplos

Architecture Agent

Gameplay Agent

Combat Agent

Narrative Agent

Quest Agent

Economy Agent

Testing Agent

Documentation Agent

Performance Agent

UI Agent

Animation Agent

Audio Agent

Localization Agent

Refactoring Agent

Validation Agent

Cada agente posee una única responsabilidad.

---

# **Paralelización**

Siempre que sea posible:

Los agentes trabajan en paralelo.

El Orchestrator integra resultados.

Reduce tiempo.

Reduce costo.

Reduce contexto.

---

# **Validation Gate**

Antes de aprobar un cambio:

Debe verificar:

Compila.

Tests exitosos.

Documentación actualizada.

State actualizado.

ADR actualizado.

Backlog consistente.

Sin conflictos.

Solo entonces:

La máquina de estados cambia.

---

# **Claude Code Standards**

Claude Code debe comportarse como un Senior Software Engineer.

Nunca como un simple generador de código.

---

## **Antes de programar**

Siempre leer:

Current State

Arquitectura

Coding Standards

ADRs

Loop

Nunca comenzar directamente a escribir código.

---

## **Durante la implementación**

Modificar únicamente los archivos necesarios.

No romper compatibilidad.

Evitar duplicación.

Mantener modularidad.

Mantener consistencia.

---

## **Después**

Siempre:

Compilar.

Ejecutar pruebas.

Actualizar Vault.

Actualizar State.

Actualizar documentación.

Actualizar backlog.

---

# **Principio de Mínimo Cambio**

Los cambios deben ser pequeños.

Fáciles de revisar.

Fáciles de revertir.

Fáciles de comprender.

---

# **Principio de Evidencia**

Si una decisión no puede justificarse mediante información existente en el Vault:

No debe asumirse.

Debe documentarse.

---

# **Principio de Sincronización**

Código.

Documentación.

Estado.

Backlog.

Arquitectura.

Siempre deben representar la misma realidad.

---

# **ADR**

Toda decisión importante genera un registro.

Título

Fecha

Contexto

Alternativas

Razón

Consecuencias

Estado  
---

# **Retroalimentación**

Cada loop genera aprendizaje.

Si un loop produce errores repetitivos:

No solo se mejora el código.

Se mejora el loop.

El sistema aprende.

---

# **Estructura sugerida del Vault**

Vault/

Knowledge/

State/

Loops/

Scheduler/

Agents/

Architecture/

ADR/

Coding Standards/

Production/

Backlog/

Roadmap/

Retrospectives/

Templates/

Prompts/

Assets/

Automation/  
---

# **Visión a Largo Plazo**

Este framework no está diseñado para Claude Code.

Claude Code es únicamente el primer motor de ejecución.

En el futuro, el mismo Vault debería poder ser ejecutado por cualquier combinación de modelos, agentes o herramientas compatibles con los contratos definidos por el sistema.

El objetivo final es que el conocimiento, los procesos y el estado del proyecto sean completamente independientes del proveedor de IA.

Los modelos cambiarán.

Las herramientas cambiarán.

Los prompts desaparecerán.

Pero el Vault permanecerá como la representación viva del proyecto y como el sistema operativo que gobierna su evolución.

---

## **Roadmap de evolución del framework**

### **V1 — Vault-Driven Development**

* Vault como fuente única de verdad.  
* Programming Loops.  
* Máquina de estados.  
* Claude Code como runtime principal.

### **V2 — Multi-Agent Runtime**

* Orquestación de múltiples agentes especializados.  
* Ejecución paralela de tareas.  
* Selección dinámica de modelos según costo, capacidad y contexto.

### **V3 — Autonomous Development Platform**

* Scheduler basado en reglas y prioridades.  
* Loops autoencadenables.  
* Gates de validación automáticos.  
* Métricas de calidad y productividad.  
* Aprendizaje continuo del propio framework mediante retrospectivas y refinamiento de loops.

---

## **Regla de oro**

**Antes de modificar el proyecto, comprender el estado. Antes de cambiar el estado, seguir un loop. Antes de finalizar un loop, actualizar el Vault.**

**El Vault no documenta el desarrollo. El Vault dirige el desarrollo.**

