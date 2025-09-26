// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/// @title KipuBank — bóvedas personales para ETH con límites globales y por retiro
/// @author 
/// @notice Contrato seguro para depositar y retirar ETH 
/// @dev Usa errores personalizados, patrón checks-effects-interactions, eventos, NatSpec y funciones bien documentadas
contract KipuBank {

    /*/////////////////////////////////////////////////////////////
                              ERRORES
    /////////////////////////////////////////////////////////////*/

    /// @notice Se lanza cuando un depósito supera el límite global del banco
    error LimiteBancoExcedido(uint256 intentado, uint256 disponible);

    /// @notice Se lanza cuando el usuario intenta retirar más de lo que tiene
    error SaldoInsuficiente(uint256 disponible, uint256 solicitado);

    /// @notice Se lanza cuando el monto a retirar supera el límite por transacción
    error RetiroExcedeLimite(uint256 solicitado, uint256 limite);

    /// @notice Se lanza cuando se intenta depositar o retirar 0
    error MontoCero();

    /// @notice Se lanza cuando falla la transferencia nativa de ETH
    error TransferenciaFallida(address destino, uint256 monto);

    /*/////////////////////////////////////////////////////////////
                         VARIABLES INMUTABLES
    /////////////////////////////////////////////////////////////*/

    /// @notice Límite máximo de ETH que puede tener el banco en total
    uint256 public immutable limiteBanco;

    /// @notice Límite máximo de ETH que un usuario puede retirar en una sola transacción
    uint256 public immutable limiteRetiro;

    /*/////////////////////////////////////////////////////////////
                           VARIABLES DE ESTADO
    /////////////////////////////////////////////////////////////*/

    /// @notice Total de ETH actualmente depositado en el banco
    uint256 public totalDepositado;

    /// @notice Contador de depósitos realizados
    uint256 public contadorDepositos;

    /// @notice Contador de retiros realizados
    uint256 public contadorRetiros;

    /// @notice Saldo de cada usuario
    mapping(address => uint256) private saldos;

    /*/////////////////////////////////////////////////////////////
                               EVENTOS
    /////////////////////////////////////////////////////////////*/

    /// @notice Evento emitido cuando un usuario deposita ETH
    event Deposito(address indexed usuario, uint256 monto, uint256 nuevoSaldo);

    /// @notice Evento emitido cuando un usuario retira ETH
    event Retiro(address indexed usuario, uint256 monto, uint256 nuevoSaldo);

    /*/////////////////////////////////////////////////////////////
                             CONSTRUCTOR
    /////////////////////////////////////////////////////////////*/

    /// @param _limiteBanco Límite global en wei
    /// @param _limiteRetiro Límite por transacción en wei
    constructor(uint256 _limiteBanco, uint256 _limiteRetiro) {
        limiteBanco = _limiteBanco;
        limiteRetiro = _limiteRetiro;
    }

    /*/////////////////////////////////////////////////////////////
                             MODIFICADORES
    /////////////////////////////////////////////////////////////*/

    /// @dev Verifica que el monto no sea cero
    modifier montoNoCero(uint256 valor) {
        if (valor == 0) revert MontoCero();
        _;
    }

    /*/////////////////////////////////////////////////////////////
                             FUNCIONES PÚBLICAS
    /////////////////////////////////////////////////////////////*/

    /// @notice Deposita ETH en la bóveda del usuario
    function depositar() external payable {
        _depositar(msg.sender, msg.value);
    }

    /// @notice Retira ETH de la bóveda del usuario
    /// @param monto Cantidad a retirar en wei
    function retirar(uint256 monto) external montoNoCero(monto) {
        uint256 saldo = saldos[msg.sender];

        // Checks
        if (monto > saldo) revert SaldoInsuficiente(saldo, monto);
        if (monto > limiteRetiro) revert RetiroExcedeLimite(monto, limiteRetiro);

        // Effects
        saldos[msg.sender] = saldo - monto;
        totalDepositado -= monto;
        unchecked { contadorRetiros++; }

        // Interactions
        _transferenciaSegura(msg.sender, monto);

        emit Retiro(msg.sender, monto, saldos[msg.sender]);
    }

    /// @notice Consulta el saldo de un usuario
    /// @param usuario Dirección del usuario
    /// @return saldo en wei
    function saldoDe(address usuario) external view returns (uint256) {
        return saldos[usuario];
    }

    /*/////////////////////////////////////////////////////////////
                           FUNCIONES PRIVADAS
    /////////////////////////////////////////////////////////////*/

    /// @dev Lógica de depósito compartida por depositar() y receive()
    function _depositar(address usuario, uint256 monto) private {
        uint256 nuevoTotal = totalDepositado + monto;

        // Checks
        if (nuevoTotal > limiteBanco) revert LimiteBancoExcedido(nuevoTotal, limiteBanco - totalDepositado);

        // Effects
        saldos[usuario] += monto;
        totalDepositado = nuevoTotal;
        unchecked { contadorDepositos++; }

        emit Deposito(usuario, monto, saldos[usuario]);
    }

    /// @dev Transferencia segura de ETH
    function _transferenciaSegura(address destino, uint256 monto) private {
        (bool ok, ) = destino.call{value: monto}("");
        if (!ok) revert TransferenciaFallida(destino, monto);
    }

    /*/////////////////////////////////////////////////////////////
                          FUNCIONES ESPECIALES
    /////////////////////////////////////////////////////////////*/

    /// @notice Permite recibir ETH directamente como depósito
    receive() external payable {
        _depositar(msg.sender, msg.value);
    }
}
