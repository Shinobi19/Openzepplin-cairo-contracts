mod account;
mod erc1155;
mod erc20;
mod erc721;
mod eth_account;

use account::IAccountUpgradeable;
use account::{IAccountUpgradeableDispatcher, IAccountUpgradeableDispatcherTrait};
use erc1155::IERC1155Upgradeable;
use erc1155::{IERC1155UpgradeableDispatcher, IERC1155UpgradeableDispatcherTrait};
use erc20::IERC20Upgradeable;
use erc20::{IERC20UpgradeableDispatcher, IERC20UpgradeableDispatcherTrait};
use erc721::IERC721Upgradeable;
use erc721::{IERC721UpgradeableDispatcher, IERC721UpgradeableDispatcherTrait};
use eth_account::IEthAccountUpgradeable;
use eth_account::{IEthAccountUpgradeableDispatcher, IEthAccountUpgradeableDispatcherTrait};
