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

    let user_1 = env.create_light_account();

    // @dev - Create the LogisticsOrderManagement contract instance
    let logistics_order_management = LogisticsOrderManagement::at(contract_address);

    // @dev - Get a current order_id
    let current_order_id = env.view_public(logistics_order_management.get_order_id());
    debug_log_format("--------- current_order_id: {0} ---------", [current_order_id as Field]);

    // @dev - Get the next block number
    let next_block_number = env.next_block_number();

    // @dev - Create a new order
    env.call_private(user_1, logistics_order_management.create_new_order(current_order_id, next_block_number));
    // @dev - Get the order_id after new order creation
    //let order_id = env.view_public(LogisticsOrderManagement::at(contract_address).get_order_id());
    //debug_log_format("--------- order_id: {0} ---------", [order_id as Field]);

    //assert(order_id == 1);
}

#[test]
unconstrained fn does_it_fail_to_call_the_initializer() {
    let mut env = aztec::test::helpers::test_environment::TestEnvironment::new();

    let owner = env.create_light_account();
    let user_1 = env.create_light_account();

    let initializer_call_interface = LogisticsOrderManagement::interface().constructor(owner);
    let logistics_order_management_deployer = env.deploy("@logistics_order_management_contract/LogisticsOrderManagement");
    let contract_address =
        logistics_order_management_deployer.with_public_initializer(owner, initializer_call_interface);

    // @dev - Create the LogisticsOrderManagement contract instance
    let logistics_order_management = LogisticsOrderManagement::at(contract_address);

    // @dev - Get a current order_id
    let current_order_id = env.view_public(logistics_order_management.get_order_id());
    debug_log_format("--------- current_order_id: {0} ---------", [current_order_id as Field]);

    // @dev - Get the next block number
    let next_block_number = env.next_block_number();

    // @dev - Create a new order
    env.call_private(user_1, logistics_order_management.create_new_order(current_order_id, next_block_number));

    // @dev - Get the order_id after new order creation
    //let order_id = env.view_public(LogisticsOrderManagement::at(contract_address).get_order_id());
    //debug_log_format("--------- order_id: {0} ---------", [order_id as Field]);
    
    //assert(order_id == 1);
}
