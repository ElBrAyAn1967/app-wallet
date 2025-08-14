// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * ============================
 * Contrato educativo de NFT
 * Nombre: Frutero
 * Red: Monad Testnet
 * Storage de imágenes/metadata: Piñata (IPFS)
 * ============================
 * Este contrato sigue el estándar ERC-721 y añade:
 * - Mint público con precio
 * - Límite de supply y por wallet
 * - Royalties (ERC-2981)
 * - Withdraw de fondos
 * - Base URI en Piñata/IPFS
 */

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";

contract Frutero is ERC721, ERC2981, Ownable {
    // ===== CONFIGURACIÓN =====
    uint256 public constant MAX_SUPPLY = 10000; // máximo de NFTs
    uint256 public mintPrice = 0.01 ether;      // precio por NFT
    uint256 public maxPerWallet = 5;            // límite por wallet
    bool    public mintOpen = true;             // habilitar/deshabilitar mint

    // Enlace base a Piñata/IPFS (ej: ipfs://CID/)
    string  private baseTokenURI;

    // Siguiente ID a mintear (comenzamos en 1 por estética)
    uint256 private _nextTokenId = 1;

    // Registro de cuántos ha minteado cada wallet
    mapping(address => uint256) public mintedPerWallet;

    /**
     * @param _name Nombre de la colección
     * @param _symbol Símbolo del token
     * @param _baseURI_ Base URI de Piñata (termina en "/")
     * @param royaltyReceiver Dirección que recibe los royalties
     * @param royaltyBps Porcentaje de royalties (500 = 5%)
     */
    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseURI_,
        address royaltyReceiver,
        uint96 royaltyBps
    )
        ERC721(_name, _symbol)
        Ownable(msg.sender)
    {
        // Guardamos la URL base en IPFS/Piñata
        baseTokenURI = _baseURI_;

        // Configuramos royalties si se pasan parámetros
        if (royaltyReceiver != address(0) && royaltyBps > 0) {
            _setDefaultRoyalty(royaltyReceiver, royaltyBps);
        }
    }

    // ===== ADMIN =====
    function setBaseURI(string memory _base) external onlyOwner {
        baseTokenURI = _base;
    }

    function setMintOpen(bool _open) external onlyOwner {
        mintOpen = _open;
    }

    function setMintPrice(uint256 _price) external onlyOwner {
        mintPrice = _price;
    }

    function setMaxPerWallet(uint256 _max) external onlyOwner {
        maxPerWallet = _max;
    }

    function setDefaultRoyalty(address receiver, uint96 feeNumerator) external onlyOwner {
        _setDefaultRoyalty(receiver, feeNumerator);
    }

    // ===== MINT PÚBLICO =====
    function mint(uint256 qty) external payable {
        require(mintOpen, "Mint cerrado");
        require(qty > 0 && qty <= 10, "Cantidad invalida");
        require(msg.value == mintPrice * qty, "Monto incorrecto");
        require(_nextTokenId + qty - 1 <= MAX_SUPPLY, "Excede supply");
        require(mintedPerWallet[msg.sender] + qty <= maxPerWallet, "Limite wallet");

        mintedPerWallet[msg.sender] += qty;

        unchecked {
            for (uint256 i = 0; i < qty; ++i) {
                _safeMint(msg.sender, _nextTokenId);
                _nextTokenId++;
            }
        }
    }

    // ===== AIRDROP (solo owner) =====
    function airdrop(address to, uint256 qty) external onlyOwner {
        require(_nextTokenId + qty - 1 <= MAX_SUPPLY, "Excede supply");
        unchecked {
            for (uint256 i = 0; i < qty; ++i) {
                _safeMint(to, _nextTokenId);
                _nextTokenId++;
            }
        }
    }

    // ===== RETIRAR FONDOS =====
    function withdraw(address payable to) external onlyOwner {
        (bool ok, ) = to.call{value: address(this).balance}("");
        require(ok, "Withdraw fallo");
    }

    // ===== INTERNOS =====
    function _baseURI() internal view override returns (string memory) {
        return baseTokenURI;
    }

    /// Soporte de interfaces ERC-721 + ERC-2981
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC2981)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
