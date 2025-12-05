use crate::{
    LogisticsOrderManagement, 
    test::utils
};

// @dev - Import debug logging
use dep::aztec::oracle::debug_log::{
    debug_log,
    debug_log_format,
    debug_log_format_slice,
    debug_log_format_with_level,
    debug_log_with_level,
};


#[test]
unconstrained fn new_order_creation_should_be_success() {
    let (env, contract_address, owner, _) = utils::setup_contract(false);

    // @dev - Get a current order_id
    let current_order_id = env.view_public(LogisticsOrderManagement::at(contract_address).get_order_id());
    debug_log_format("--------- current_order_id: {0} ---------", [current_order_id as Field]);

    // @dev - Create a new order
    env.call_private(owner, LogisticsOrderManagement::at(contract_address).create_new_order(current_order_id));

    let order_id = env.view_public(LogisticsOrderManagement::at(contract_address).get_order_id());
    assert(order_id == 1);
}

#[test]
unconstrained fn does_it_fail_to_call_the_initializer() {
    let mut env = aztec::test::helpers::test_environment::TestEnvironment::new();

    let owner = env.create_light_account();

    let initializer_call_interface = LogisticsOrderManagement::interface().constructor(owner);
    let logistics_order_management_deployer = env.deploy("@logistics_order_management_contract/LogisticsOrderManagement");
    let contract_address =
        logistics_order_management_deployer.with_public_initializer(owner, initializer_call_interface);

    // @dev - Get a current order_id
    let current_order_id = env.view_public(LogisticsOrderManagement::at(contract_address).get_order_id());
    debug_log_format("--------- current_order_id: {0} ---------", [current_order_id as Field]);

    // @dev - Create a new order
    env.call_private(owner, LogisticsOrderManagement::at(contract_address).create_new_order(current_order_id));
    let order_id = env.view_public(LogisticsOrderManagement::at(contract_address).get_order_id());
    assert(order_id == 1);
}
