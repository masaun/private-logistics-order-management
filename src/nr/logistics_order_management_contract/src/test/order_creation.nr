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


/**
 * @notice - Test for the new_order_creation(), which should be successful.
 */
#[test]
unconstrained fn new_order_creation_should_be_success() {
    // @dev - Setup the test environment and deploy the contract + Create accounts (owner and user_1)
    let (env, contract_address, owner, user_1) = utils::setup_contract(false);

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
    let order_id_after_new_order_creation = env.view_public(LogisticsOrderManagement::at(contract_address).get_order_id());
    debug_log_format("--------- order_id_after_new_order_creation: {0} ---------", [order_id_after_new_order_creation as Field]); // [Result]: "order_id: 0x0000000000000000000000000000000000000000000000000000000000000001"

    // @dev - Check whether the order_id is properly incremented or not
    assert(order_id_after_new_order_creation == 1);
    //assert(order_id_after_new_order_creation as Field == 0x0000000000000000000000000000000000000000000000000000000000000001);
}


/**
 * @notice - This test is almost same with above "new_order_creation_should_be_success" test.
 * @notice - The only difference is that this test visibly deploys the contract with initializer function.
 */
#[test]
unconstrained fn new_order_creation_with_visible_procedure_should_be_success() {
    let mut env = aztec::test::helpers::test_environment::TestEnvironment::new();

    // @dev - Create accounts (owner and user_1)
    let owner = env.create_light_account();
    let user_1 = env.create_light_account();

    // @dev - Deploy / Initialize the LogisticsOrderManagement contract
    let initializer_call_interface = LogisticsOrderManagement::interface().constructor(owner);
    let logistics_order_management_deployer = env.deploy("@logistics_order_management_contract/LogisticsOrderManagement");
    let contract_address = logistics_order_management_deployer.with_public_initializer(owner, initializer_call_interface);

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
    let order_id_after_new_order_creation = env.view_public(logistics_order_management.get_order_id());
    debug_log_format("--------- order_id_after_new_order_creation: {0} ---------", [order_id_after_new_order_creation as Field]); // [Result]: "order_id: 0x0000000000000000000000000000000000000000000000000000000000000001"

    // @dev - Check whether the order_id is properly incremented or not
    assert(order_id_after_new_order_creation == 1);
    //assert(order_id_after_new_order_creation as Field == 0x0000000000000000000000000000000000000000000000000000000000000001);
}


/**
 * @notice - Test for the update_existing_order(), which should be successful.
 */
#[test]
unconstrained fn update_existing_order_should_be_success() {
    // @dev - Setup the test environment and deploy the contract + Create accounts (owner and user_1)
    let (env, contract_address, owner, user_1) = utils::setup_contract(false);

    // @dev - Create the LogisticsOrderManagement contract instance
    let logistics_order_management = LogisticsOrderManagement::at(contract_address);

    // @dev - Get a current order_id
    let current_order_id = env.view_public(logistics_order_management.get_order_id());
    debug_log_format("--------- current_order_id: {0} ---------", [current_order_id as Field]);

    // @dev - Create a new order
    let next_block_number = env.next_block_number();
    env.call_private(user_1, logistics_order_management.create_new_order(current_order_id, next_block_number));

    // @dev - Update the existing order
    let new_order_quantity: u128 = 250; // New order quantity to be updated
    let new_order_block_number: u32 = env.next_block_number(); // New block number
    env.call_private(user_1, logistics_order_management.update_existing_order(current_order_id, new_order_quantity, new_order_block_number));

    // @dev - [TODO]: Check whether the order_quantity is properly updated or not
    // @dev - [HINT]: The view_notes() method is used in the nft_contract - main.nr:  https://github.com/masaun/private-logistics-management-system/pull/18#issuecomment-3629824900
    //let updated_order_quantity = env.view_private(logistics_order_management.get_order_detail(current_order_id));
    //debug_log_format("--------- updated_order_quantity: {0} ---------", [updated_order_quantity as Field]);
    //assert(updated_order_quantity == 250);
}