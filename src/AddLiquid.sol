// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interfaces/IUniswapV2Pair.sol";
import {IERC20} from "./interfaces/IERC20.sol";

contract AddLiquid {
    /**
     *  ADD LIQUIDITY WITHOUT ROUTER EXERCISE
     *
     *  The contract has an initial balance of 1000 USDC and 1 WETH.
     *  Mint a position (deposit liquidity) in the pool USDC/WETH to msg.sender.
     *  The challenge is to provide the same ratio as the pool then call the mint function in the pool contract.
     *
     */
    function addLiquidity(address usdc, address weth, address pool, uint256 usdcReserve, uint256 wethReserve) public {
        IUniswapV2Pair pair = IUniswapV2Pair(pool);
        // your code start here
        uint256 amountA; // USDC
        uint256 amountB; // WETH
        uint256 amountADesired = IERC20(usdc).balanceOf(address(this)); // 1000 USDC
        uint256 amountBDesired = IERC20(weth).balanceOf(address(this)); // 1 WETH
        if (usdcReserve == 0 && wethReserve == 0) {
            (amountA, amountB) = (amountADesired, amountBDesired);
        } else {
            // Based on the ratio what is present in the pool we need to calculate the amount of USDC and WETH to be transferred to the pool
            uint amountBOptimal = quote(amountADesired, usdcReserve, wethReserve);
            if (amountBOptimal <= amountBDesired) {
                require(amountBOptimal > 0, 'INSUFFICIENT_B_AMOUNT');
                (amountA, amountB) = (amountADesired, amountBOptimal);
            } else {
                uint amountAOptimal = quote(amountBDesired, wethReserve, usdcReserve);
                assert(amountAOptimal <= amountADesired);
                require(amountAOptimal > 0, 'INSUFFICIENT_A_AMOUNT');
                (amountA, amountB) = (amountAOptimal, amountBDesired);
            }
        }
        IERC20(usdc).transfer(pool, amountA);
        IERC20(weth).transfer(pool, amountB);
        uint256 liquidity = pair.mint(msg.sender);
        require(liquidity > 0, "AddLiquid: liquidity is 0");
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'INSUFFICIENT_LIQUIDITY');
        amountB = amountA * reserveB / reserveA;
    }
}
