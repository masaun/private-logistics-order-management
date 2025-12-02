use crate::{LogisticsOrderManagement, test::utils};

#[test]
unconstrained fn increment_success() {
    let (env, contract_address, owner, _) = utils::setup_contract(false);

    env.call_private(owner, LogisticsOrderManagement::at(contract_address).increment());

    let counter = env.view_public(LogisticsOrderManagement::at(contract_address).get_counter());
    assert(counter == 1);
}

#[test]
unconstrained fn does_it_fail_to_call_the_initializer() {
    let mut env = aztec::test::helpers::test_environment::TestEnvironment::new();

    let owner = env.create_light_account();

    let initializer_call_interface = LogisticsOrderManagement::interface().constructor(owner);
    let logistics_order_management_deployer = env.deploy("@logistics_order_management_contract/LogisticsOrderManagement");
    let contract_address =
        logistics_order_management_deployer.with_public_initializer(owner, initializer_call_interface);

    env.call_private(owner, LogisticsOrderManagement::at(contract_address).increment());
    let counter = env.view_public(LogisticsOrderManagement::at(contract_address).get_counter());
    assert(counter == 1);
}
