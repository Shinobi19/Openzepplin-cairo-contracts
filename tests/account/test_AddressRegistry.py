import pytest
from utils import TestSigner, contract_path, State, Account


signer = TestSigner(123456789987654321)
L1_ADDRESS = 0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984
ANOTHER_ADDRESS = 0xd9e1ce17f2641f24ae83637ab66a2cca9c378b9f


@pytest.fixture(scope='module')
async def account_factory():
    starknet = await State.init()
    account = Account.deploy(signer.public_key)
    registry = await starknet.deploy(
        contract_path("openzeppelin/account/AddressRegistry.cairo")
    )

    return account, registry


@pytest.mark.asyncio
async def test_set_address(account_factory):
    account, registry = account_factory

    await signer.send_transaction(account, registry.contract_address, 'set_L1_address', [L1_ADDRESS])
    execution_info = await registry.get_L1_address(account.contract_address).call()
    assert execution_info.result == (L1_ADDRESS,)


@pytest.mark.asyncio
async def test_update_address(account_factory):
    account, registry = account_factory

    await signer.send_transaction(account, registry.contract_address, 'set_L1_address', [L1_ADDRESS])

    execution_info = await registry.get_L1_address(account.contract_address).call()
    assert execution_info.result == (L1_ADDRESS,)

    # set new address
    await signer.send_transaction(account, registry.contract_address, 'set_L1_address', [ANOTHER_ADDRESS])

    execution_info = await registry.get_L1_address(account.contract_address).call()
    assert execution_info.result == (ANOTHER_ADDRESS,)
