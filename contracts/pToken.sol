pragma solidity ^0.6.2;

import "@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC777/ERC777Upgradeable.sol";

import "./ERC777GSN.sol";
import "./ERC777WithAdminOperator.sol";

contract PToken is
    Initializable,
    AccessControlUpgradeable,
    ERC777Upgradeable,
    ERC777GSNUpgreadable,
    ERC777WithAdminOperatorUpgreadable
{
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    event Redeem(
        address indexed redeemer,
        uint256 value,
        string underlyingAssetRecipient
    );

    function initialize(
        string memory tokenName,
        string memory tokenSymbol,
        address[] memory defaultOperators
    ) 
        public initializer {
            __AccessControl_init();
            __ERC777_init(tokenName, tokenSymbol, defaultOperators);
            __ERC777GSNUpgreadable_init(_msgSender(), _msgSender());
            __ERC777WithAdminOperatorUpgreadable_init(_msgSender());
            _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
            _setupRole(MINTER_ROLE, _msgSender());
    }

    function mint(
        address recipient,
        uint256 value
    )
        external
        returns (bool)
    {
        mint(recipient, value, "", "");
        return true;
    }

    function mint(
        address recipient,
        uint256 value,
        bytes memory userData,
        bytes memory operatorData
    )
        public        
        returns (bool)
    {
        require(hasRole(MINTER_ROLE, _msgSender()), "Caller is not a minter");
        _mint(recipient, value, userData, operatorData);
        return true;
    }

    function redeem(
        uint256 amount,
        string calldata underlyingAssetRecipient
    )
        external
        returns (bool)
    {
        redeem(amount, "", underlyingAssetRecipient);
        return true;
    }

    function redeem(
        uint256 amount,
        bytes memory data,
        string memory underlyingAssetRecipient
    )
        public
    {
        _burn(_msgSender(), amount, data, "");
        emit Redeem(_msgSender(), amount, underlyingAssetRecipient);
    }

    function operatorRedeem(
        address account,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData,
        string calldata underlyingAssetRecipient
    )
        external
    {
        require(
            isOperatorFor(_msgSender(), account),
            "ERC777: caller is not an operator for holder"
        );
        _burn(account, amount, data, operatorData);
        emit Redeem(account, amount, underlyingAssetRecipient);
    }

    function grantMinterRole(address _account) external {
        grantRole(MINTER_ROLE, _account);
    }

    function revokeMinterRole(address _account) external {
        revokeRole(MINTER_ROLE, _account);
    }

    function hasMinterRole(address _account) external view returns (bool) {
        return hasRole(MINTER_ROLE, _account);
    }

    function _msgSender() internal view override(ContextUpgradeable, ERC777GSNUpgreadable) returns (address payable) {
        return GSNRecipientUpgradeable._msgSender();
  }

    function _msgData() internal view override(ContextUpgradeable, ERC777GSNUpgreadable) returns (bytes memory) {
        return GSNRecipientUpgradeable._msgData();
    }
}
