pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC2981Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import '@openzeppelin/contracts/utils/Base64.sol';

import "../libs/helpers/Errors.sol";
import "../libs/structs/CryptoAIStructsLibs.sol";
import "../interfaces/ICryptoAIData.sol";

import 'hardhat/console.sol';

contract CryptoAI is Initializable, ERC721Upgradeable, ERC721URIStorageUpgradeable, IERC2981Upgradeable, OwnableUpgradeable {
    uint256 public constant TOKEN_LIMIT = 10000; // Changed to 10000
    uint256 public constant MINT_PRINT = 1 ** 18; // Changed to 10000

    // super admin
    address public _admin;
    // parameter control address
    address public _paramsAddress;
    // randomizer
    address public _randomizerAddr;
    // deployer
    address public _deployer;
    // CryptoAIData
    address public _cryptoAiDataAddr;

    bool private _contractSealed;
    uint256 public _indexMint;
    mapping(address => uint256) public _allowList;

    mapping(uint256 => uint256) public seedTokenId;

    modifier unsealed() {
        require(!_contractSealed, Errors.CONTRACT_SEALED);
        _;
    }

    modifier onlyDeployer() {
        require(msg.sender == _deployer, Errors.ONLY_DEPLOYER);
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == _deployer, Errors.ONLY_ADMIN_ALLOWED);
        _;
    }

    function initialize(
        string memory name,
        string memory symbol,
        address admin,
        address deployer,
        address paramsAddress,
        address random,
        address cryptoAiData
    ) initializer public {
        _admin = admin;
        _deployer = deployer;
        _cryptoAiDataAddr = cryptoAiData;
        _randomizerAddr = random;
        _paramsAddress = paramsAddress;
        _contractSealed = false;
        _indexMint = 1;

        __ERC721_init(name, symbol);
        __ERC721URIStorage_init();
        __Ownable_init();
    }

    function changeAdmin(address newAdm) external onlyAdmin {
        require(msg.sender == _admin && newAdm != Errors.ZERO_ADDR, Errors.ONLY_ADMIN_ALLOWED);
        if (_admin != newAdm) {
            address _previousAdmin = _admin;
            _admin = newAdm;
        }
    }

    function changeDeployer(address newAdm) external onlyAdmin {
        require(newAdm != Errors.ZERO_ADDR, Errors.INV_ADD);
        if (_deployer != newAdm) {
            _deployer = newAdm;
        }
    }

    function changeParamAddr(address newAddr) external onlyAdmin {
        require(msg.sender == _admin && newAddr != Errors.ZERO_ADDR, Errors.ONLY_ADMIN_ALLOWED);

        // change
        if (_paramsAddress != newAddr) {
            _paramsAddress = newAddr;
        }
    }

    function changeCryptoAiDataAddress(address newAddr) external onlyAdmin {
        require(newAddr != Errors.ZERO_ADDR, Errors.ONLY_ADMIN_ALLOWED);

        if (_cryptoAiDataAddr != newAddr) {
            _cryptoAiDataAddr = newAddr;
        }
    }

    function setAllowList(address[] memory allowList) public onlyDeployer unsealed {
        for (uint256 i = 0; i < allowList.length; i++) {
            require(_allowList[allowList[i]] == 0);
            _allowList[allowList[i]] = 1;
        }
    }

    function adminMint(address to) public {
        require(_indexMint < 1000);
        require(msg.sender == _deployer);
        require(to != Errors.ZERO_ADDR, Errors.INV_ADD);
        _safeMint(to, _indexMint);
        _indexMint++;
    }

    //@ERC721
    function mint(address to) public payable {
        require(to != Errors.ZERO_ADDR, Errors.INV_ADD);
        require(_indexMint <= TOKEN_LIMIT);
        _safeMint(to, _indexMint);
        uint256 seed = uint256(keccak256(abi.encodePacked(block.timestamp, to, _indexMint)));
        seedTokenId[_indexMint] = seed;
        emit CryptoAIStructs.TokenMinted(_indexMint);
        _indexMint += 1;
    }

    function checkUnlockedNFT(uint256 tokenID) external pure returns (bool) {
        return tokenID % 2 == 0;
    }

    function _burn(uint256 tokenId) internal override(ERC721Upgradeable, ERC721URIStorageUpgradeable) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721Upgradeable, ERC721URIStorageUpgradeable) returns (string memory result) {
        require(_exists(tokenId), 'ERC721: Token does not exist');
        ICryptoAIData cryptoAIDataContract = ICryptoAIData(_cryptoAiDataAddr);
        result = string(
            abi.encodePacked(
                'data:application/json;base64,',
                Base64.encode(
                    abi.encodePacked(
                        '{',
                        '"image": "',
                        cryptoAIDataContract.renderFullSVGWithGrid(tokenId),
                        '}'
                    )
                )
            )
        );
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Upgradeable, ERC721URIStorageUpgradeable, IERC165Upgradeable) returns (bool) {
        return
            interfaceId == type(ERC721URIStorageUpgradeable).interfaceId || interfaceId == type(IERC2981Upgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /* @dev EIP2981 royalties implementation.
    // EIP2981 standard royalties return.
    */
    function royaltyInfo(uint256 _tokenId, uint256 _salePrice) external view virtual override
    returns (address receiver, uint256 royaltyAmount) {
        receiver = this.owner();
        royaltyAmount = _salePrice * 0 / 10000;
    }

    /* @CryptoAI */
    function sealContract() external onlyDeployer unsealed {
        _contractSealed = true;
    }
}