var Payroll = artifacts.require("./Payroll.sol");


contract('Payroll', function (accounts) {
    owner = accounts[0];

    // 1. test addEmployee function      
    it("...add employee successfully", function () {
        return Payroll.deployed().then(function (instance) {
            payroll = instance;
            return payroll.addEmployee(accounts[1], 1);
        }).then(function () {
            return payroll.employees.call(accounts[1]);
        }).then(function (employee) {
            employee_1 = employee[0];
        }).then(function () {
            return payroll.addEmployee(accounts[2], 2);
        }).then(function () {
            return payroll.employees.call(accounts[2]);
        }).then(function (employee) {
            employee_2 = employee[0];
        }).then(function () {
            // test add employee that exists before
            return payroll.addEmployee(accounts[2], 2);
        }).then(function () {
            amount = web3.toWei(9, "ether")
            return payroll.addFund({ from: owner, value: amount });
        }).then(function () {
            return payroll.calculateRunway.call();
        }).then(function (count) {
            assert.equal(employee_1, accounts[1], "add employee_1 successfully");
            assert.equal(employee_2, accounts[2], "add employee_2 successfully");
            assert.equal(3, count, "skip adding existing employees");
        });
    });

    // 2. test addEmployee function by nonowner   
    it("...add employee by nonowner failed", function () {
        return Payroll.deployed().then(function (instance) {
            payroll = instance;
            exception = false;
            return payroll.addEmployee(accounts[1], 1, { from: accounts[1] });
        }).catch(function (error) {
            exception = true;
        }).then(function () {
            assert.equal(exception, true, "should raise exception when add employee by nonowner");
        });
    });

    // 3. test removeEmployee 
    it("...remove employee successfully", function () {
        return Payroll.deployed().then(function (instance) {
            payroll = instance;
            return payroll.addEmployee(accounts[1], 1);
        }).then(function () {
            return payroll.employees.call(accounts[1]);
        }).then(function (employee) {
            employee_1 = employee[0];
        }).then(function () {
            return payroll.removeEmployee(accounts[1]);
        }).then(function () {
            return payroll.employees.call(accounts[1]);
        }).then(function (employee) {
            employee_2 = employee[0];
        }).then(function () {
            assert(employee_1, accounts[1], "add employee_1 successfully");
            assert(employee_2, 0, "remove employee_1 successfully");
        });
    });

    // 4. test removeEmployee by nonowner
    it("...remove employee by nonowner failed", function () {
        return Payroll.deployed().then(function (instance) {
            payroll = instance;
            exception = false;
            return payroll.addEmployee(accounts[1], 1);
        }).then(function () {
            return payroll.removeEmployee(accounts[1], { from: accounts[2] });
        }).catch(function (error) {
            exception = true;
        }).then(function () {
            assert.equal(exception, true, "should raise exception when remove employee by nonowner");
        });
    });

    // 5. test removeEmployee not existing
    it("...remove employee not existing failed", function () {
        return Payroll.deployed().then(function (instance) {
            payroll = instance;
            exception = false;
            return payroll.addEmployee(accounts[1], 1);
        }).then(function () {
            return payroll.removeEmployee(accounts[3]);
        }).catch(function (error) {
            exception = true;
        }).then(function () {
            assert.equal(exception, true, "should raise exception when remove employee not existing");
        });
    });

    // 6. test getPaid successfully
    it("...get paid successfully", function () {
        return Payroll.deployed().then(function (instance) {
            payroll = instance;
            amount = web3.toWei(9, "ether")
            return payroll.addFund({ from: owner, value: amount });
        }).then(function () {
            return payroll.addEmployee(accounts[1], 1);
        }).then(function () {
            return payroll.employees.call(accounts[1]);
        }).then(function (employee) {
            employee_id = employee[0];
            last_pay_day = employee[2];
            employee_balance = web3.eth.getBalance(employee_id);
        }).then(function () {
            return new Promise(resolve => setTimeout(resolve, 10 * 1000));
        }).then(function () {
            return payroll.getPaid({ from: accounts[1] });
        }).then(function () {
            return payroll.employees.call(accounts[1]);
        }).then(function (employee) {
            last_pay_day_now = employee[2];
            employee_balance_now = web3.eth.getBalance(employee_id);
        }).then(function () {
            assert.ok(employee_balance_now.gt(employee_balance), "add balance successfully");
            assert.ok(last_pay_day_now.eq(last_pay_day.plus(10)), "change last pay day successfully");
        });
    });

    // 7. test getPaid by not exsiting employee failed
    it("...get paid by not exsiting employee failed", function () {
        return Payroll.deployed().then(function (instance) {
            payroll = instance;
        }).then(function () {
            return payroll.addEmployee(accounts[1], 1);
        }).then(function () {
            exception = false;
            return payroll.getPaid({ from: accounts[3] });
        }).catch(function (error) {
            exception = true;
        }).then(function () {
            assert.equal(exception, true, "should raise exception get paid by employee not existing");
        });
    });

    // 8. test getPaid when last pay day > now failed
    it("...get paid when last pay day > now failed", function () {
        return Payroll.deployed().then(function (instance) {
            payroll = instance;
            amount = web3.toWei(9, "ether")
            return payroll.addFund({ from: owner, value: amount });
        }).then(function () {
            return payroll.addEmployee(accounts[4], 1);
        }).then(function () {
            return payroll.getPaid({ from: accounts[4] });
        }).catch(function (error) {
            exception = true;
        }).then(function () {
            assert.equal(exception, true, "should raise exception when last pay day > now");
        });
    });


});