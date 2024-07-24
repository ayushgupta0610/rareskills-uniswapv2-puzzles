// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interfaces/IERC20.sol";

contract ExactSwapWithRouter {
    /**
     *  PERFORM AN EXACT SWAP WITH ROUTER EXERCISE
     *
     *  The contract has an initial balance of 1 WETH.
     *  The challenge is to swap an exact amount of WETH for 1337 USDC token using UniswapV2 router.
     *
     */
    address public immutable router;

    constructor(address _router) {
        router = _router;
    }

    function performExactSwapWithRouter(address weth, address usdc, uint256 deadline) public {
        // your code start here
        IUniswapV2Router _router = IUniswapV2Router(router);
        IERC20(weth).approve(router, 1 ether);
        address[] memory path = new address[](2);
        path[0] = weth;
        path[1] = usdc;
        uint256 amountOut = 1337 * 1e6;
        address factory = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f; // TODO: Check with Jeffrey if this is allowed (external info)
        address pair = pairFor(factory, usdc, weth);
        uint256 reserveIn = IERC20(weth).balanceOf(pair);
        uint256 reserveOut = IERC20(usdc).balanceOf(pair);
        uint256 wethAmountIn = getAmountIn(amountOut, reserveIn, reserveOut);
        _router.swapExactTokensForTokens(wethAmountIn, amountOut, path, address(this), deadline);
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {
        require(amountOut > 0, 'INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn *amountOut*1000;
        uint denominator = (reserveOut-amountOut) * 997;
        amountIn = numerator / denominator + 1;
    }

     function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        pair = address(uint160(uint256((keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(tokenA, tokenB)),
                hex'96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f' // init code hash
            ))))));
    }
}

interface IUniswapV2Router {
    /**
     *     amountIn: the amount of input tokens to swap.
     *     amountOutMin: the minimum amount of output tokens that must be received for the transaction not to revert.
     *     path: an array of token addresses. In our case, WETH and USDC.
     *     to: recipient address to receive the liquidity tokens.
     *     deadline: timestamp after which the transaction will revert.
     */
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}
