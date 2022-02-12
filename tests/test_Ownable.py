import pytest
import asyncio
from starkware.starknet.testing.starknet import Starknet
from utils import Signer, PRIVATE_KEYS, account_calldata

signer = Signer(PRIVATE_KEYS[0])


@pytest.fixture(scope='module')
def event_loop():
    return asyncio.new_event_loop()


@pytest.fixture(scope='module')
async def ownable_factory():
    starknet = await Starknet.empty()
    owner = await starknet.deploy(
        "contracts/Account.cairo",
        constructor_calldata=[
            *account_calldata(PRIVATE_KEYS[0])
        ]
    )

    ownable = await starknet.deploy(
        "contracts/Ownable.cairo",
        constructor_calldata=[owner.contract_address]
    )
    return starknet, ownable, owner


@pytest.mark.asyncio
async def test_constructor(ownable_factory):
    _, ownable, owner = ownable_factory
    expected = await ownable.get_owner().call()
    assert expected.result.owner == owner.contract_address


@pytest.mark.asyncio
async def test_transfer_ownership(ownable_factory):
    _, ownable, owner = ownable_factory
    new_owner = 123
    await signer.send_transaction(owner, ownable.contract_address, 'transfer_ownership', [new_owner])
    executed_info = await ownable.get_owner().call()
    assert executed_info.result == (new_owner,)
