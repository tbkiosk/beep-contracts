// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;
pragma abicoder v2;

import "./interfaces/ISwapRouter.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC1271.sol";
import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "./interfaces/IERC6551Account.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./lib/MinimalReceiver.sol";
import "./lib/ERC6551AccountLib.sol";


contract ERC6551Account is IERC165, IERC1271, IERC6551Account {

    // For this example, we will set the pool fee to 0.3%.
    uint24 public constant poolFee = 3000;
    uint256 public nonce;

    receive() external payable {}

    
    function swapExactInputSingle(uint256 amountIn)
        external
        returns (uint256 amountOut)
    {
        require(msg.sender == 0x4d2996e95Cc316B174c0a14B590387a86521E981, 'Not Bot Wallet');
        IERC20 usdcToken = IERC20(0x07865c6E87B9F70255377e024ace6630C1Eaa37F);
        ISwapRouter swapRouter = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);
        require(usdcToken.balanceOf(address(this)) >= amountIn, "Not enough USDC");
        uint256 beepFee = SafeMath.div(SafeMath.mul(amountIn, 2), 100);
        uint256 _ammount = SafeMath.sub(amountIn, beepFee);
        usdcToken.approve(address(swapRouter), _ammount);
        usdcToken.transferFrom(address(this), 0x449f07DC7616C43B47dbE8cF57DC1F6e34eF82F8, beepFee);
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: 0x07865c6E87B9F70255377e024ace6630C1Eaa37F,
                tokenOut: 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6,
                fee: poolFee,
                recipient: address(this),
                deadline: block.timestamp,
                amountIn: _ammount,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        amountOut = swapRouter.exactInputSingle(params);
    }

    function executeCall(
        address to,
        uint256 value,
        bytes calldata data
    ) external payable returns (bytes memory result) {
        require(msg.sender == owner(), "Not token owner");
        ++nonce;

        emit TransactionExecuted(to, value, data);

        bool success;
        (success, result) = to.call{value: value}(data);

        if (!success) {
            assembly {
                revert(add(result, 32), mload(result))
            }
        }
    }

    function token()
        external
        view
        returns (
            uint256,
            address,
            uint256
        )
    {
        return ERC6551AccountLib.token();
    }

    function owner() public view returns (address) {
        (uint256 chainId, address tokenContract, uint256 tokenId) = this.token();
        if (chainId != block.chainid) return address(0);

        return IERC721(tokenContract).ownerOf(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public pure returns (bool) {
        return (interfaceId == type(IERC165).interfaceId ||
            interfaceId == type(IERC6551Account).interfaceId);
    }

    function isValidSignature(bytes32 hash, bytes memory signature)
        external
        view
        returns (bytes4 magicValue)
    {
        bool isValid = SignatureChecker.isValidSignatureNow(owner(), hash, signature);

        if (isValid) {
            return IERC1271.isValidSignature.selector;
        }

        return "";
    }
}