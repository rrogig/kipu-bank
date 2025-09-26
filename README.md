# KipuBank 

Contrato inteligente en Solidity que implementa **bóvedas personales de ETH** con límites globales de depósito y límites máximos de retiro por transacción.  
Cada usuario puede depositar y retirar ETH de forma segura, con validaciones estrictas y eventos que registran todas las operaciones.

---

## Características

- limiteBanco: Límite máximo de ETH que puede mantener el banco en total.
- limiteRetiro: Límite máximo de ETH que un usuario puede retirar en una sola transacción.
- Depósitos y retiros con validaciones de seguridad:
  - No se permiten montos en cero
  - No se pueden superar los límites establecidos
  - No se puede retirar más del saldo disponible
- Contadores de depósitos y retiros realizados
- Eventos 'Deposito' y 'Retiro'
- Uso del patrón **checks-effects-interactions** para seguridad contra ataques de reentrancy.
- Transferencias de ETH usando llamadas seguras.

---

## Dirección del contrato desplegado

El contrato está desplegado en la red de prueba **Sepolia** con código verificado en Etherscan:  

🔗 [Ver en Etherscan]([https://sepolia.etherscan.io/tx/0xa227660c5835d0432a3ed0544ac39465cb7771ade9c6d312ed230edeefcafe03](https://sepolia.etherscan.io/address/0xd1bd2407b025841088466418eb472d9701c12b2d#code))

---

## Instrucciones de despliegue

1. Clona este repositorio o copia el contrato
2. Compila con Solidity `0.8.26` (compatible con **Remix**, **Hardhat** o **Foundry**)
3. Despliega el contrato en la red de tu preferencia indicando:
   - `limiteBanco`: Límite global en wei
   - `limiteRetiro`: Límite por transacción en wei
4. (Opcional) Verifica el contrato en un explorador de bloques como **Etherscan**

Ejemplo usando Remix:
- Seleccionar `Injected Provider - MetaMask` conectado a **Sepolia**
- Compilar con la versión `0.8.26`.
- En `Deploy`, ingresar parámetros (ej: `10000000000000000000 wei`, `1000000000000000000 wei`)
- Confirmar en MetaMask

---

## Cómo interactuar con el contrato

Puedes interactuar directamente en **Etherscan**, en **Remix**, o desde un script usando **ethers.js** o **web3.js**.

### Funciones principales

- **Depositar ETH**
  ```solidity
  function depositar() external payable
