<!DOCTYPE html>
<html>
<head>
    <title>Register User</title>
    <script>
        function showRoleFields() {
            // Hide all role-specific fields
            document.getElementById('adminFields').style.display = 'none';
            document.getElementById('customerFields').style.display = 'none';
            document.getElementById('pmFields').style.display = 'none';
            document.getElementById('supplierFields').style.display = 'none';
            document.getElementById('csFields').style.display = 'none';
            document.getElementById('dpFields').style.display = 'none';

            // Clear all role-specific fields to prevent old values
            clearRoleFields();

            // Get selected role
            const role = document.getElementById('roleSelect').value;

            // Show relevant fields and set default department
            if (role === 'admin') {
                document.getElementById('adminFields').style.display = 'block';
                document.querySelector('input[name="department"]').value = 'Admin';
            } else if (role === 'customer') {
                document.getElementById('customerFields').style.display = 'block';
            } else if (role === 'product_manager') {
                document.getElementById('pmFields').style.display = 'block';
                document.querySelector('input[name="department"]').value = 'Product Managers';
            } else if (role === 'supplier') {
                document.getElementById('supplierFields').style.display = 'block';
            } else if (role === 'customer_service') {
                document.getElementById('csFields').style.display = 'block';
                document.querySelector('input[name="department"]').value = 'Customer Service';
            } else if (role === 'delivery_person') {
                document.getElementById('dpFields').style.display = 'block';
            }
        }

        function clearRoleFields() {
            // Clear all role-specific input fields to prevent old values
            const departmentFields = document.querySelectorAll('input[name="department"]');
            departmentFields.forEach(field => field.value = '');

            document.querySelector('input[name="phone"]').value = '';
            document.querySelector('input[name="dob"]').value = '';
            document.querySelector('input[name="companyName"]').value = '';
            document.querySelector('input[name="contactPerson"]').value = '';
            document.querySelector('input[name="employeeId"]').value = '';
            document.querySelector('input[name="vehicleType"]').value = '';
            document.querySelector('input[name="licensePlate"]').value = '';
            document.querySelector('input[name="isAvailable"]').checked = false;
        }

        function validateForm() {
            const role = document.getElementById('roleSelect').value;

            // Validate required fields based on role
            if (role === 'admin' || role === 'product_manager' || role === 'customer_service') {
                const department = document.querySelector('input[name="department"]').value;
                if (!department || department.trim() === '') {
                    alert('Department is required for this role');
                    return false;
                }
            }

            if (role === 'customer') {
                const phone = document.querySelector('input[name="phone"]').value;
                const dob = document.querySelector('input[name="dob"]').value;

                if (!phone || phone.trim() === '') {
                    alert('Phone number is required for customers');
                    return false;
                }

                if (!dob) {
                    alert('Date of birth is required for customers');
                    return false;
                }
            }

            if (role === 'supplier') {
                const companyName = document.querySelector('input[name="companyName"]').value;
                const contactPerson = document.querySelector('input[name="contactPerson"]').value;

                if (!companyName || companyName.trim() === '') {
                    alert('Company name is required for suppliers');
                    return false;
                }

                if (!contactPerson || contactPerson.trim() === '') {
                    alert('Contact person is required for suppliers');
                    return false;
                }
            }

            if (role === 'customer_service') {
                const employeeId = document.querySelector('input[name="employeeId"]').value;
                if (!employeeId || employeeId.trim() === '') {
                    alert('Employee ID is required for customer service staff');
                    return false;
                }
            }

            if (role === 'delivery_person') {
                const vehicleType = document.querySelector('input[name="vehicleType"]').value;
                const licensePlate = document.querySelector('input[name="licensePlate"]').value;

                if (!vehicleType || vehicleType.trim() === '') {
                    alert('Vehicle type is required for delivery persons');
                    return false;
                }

                if (!licensePlate || licensePlate.trim() === '') {
                    alert('License plate is required for delivery persons');
                    return false;
                }
            }

            return true; // Form is valid
        }
</script>
</head>
<body>
<h2>Register New User</h2>
<%
    String error = (String) request.getAttribute("error");
    if (error != null) {
%>
<p style="color: #c62828; font-weight: 600;"><%= error %></p>
<%
    }
%>
<form method="POST" action="register" onsubmit="return validateForm()">
    <label>Role:</label><br>
    <select name="role" id="roleSelect" onchange="showRoleFields()" required>
        <option value="">-- Select Role --</option>
        <option value="admin">Admin</option>
        <option value="customer">Customer</option>
        <option value="product_manager">Product Manager</option>
        <option value="supplier">Supplier</option>
        <option value="customer_service">Customer Service</option>
        <option value="delivery_person">Delivery Person</option>
    </select><br><br>

    <label>Full Name:</label><br>
    <input type="text" name="fullName" required><br><br>

    <label>Email:</label><br>
    <input type="email" name="email" required><br><br>

    <label>Password:</label><br>
    <input type="password" name="password" required><br><br>

    <label>Address:</label><br>
    <textarea name="address"></textarea><br><br>

    <!-- Dynamic fields based on role -->
    <div id="adminFields" style="display:none;">
        <label>Department:</label><br>
        <input type="text" name="department"><br><br>
    </div>

    <div id="customerFields" style="display:none;">
        <label>Phone Number:</label><br>
        <input type="text" name="phone"><br><br>
        <label>Date of Birth:</label><br>
        <input type="date" name="dob"><br><br>
    </div>

    <div id="pmFields" style="display:none;">
        <label>Department:</label><br>
        <input type="text" name="department"><br><br>
    </div>

    <div id="supplierFields" style="display:none;">
        <label>Company Name:</label><br>
        <input type="text" name="companyName"><br><br>
        <label>Contact Person:</label><br>
        <input type="text" name="contactPerson"><br><br>
    </div>

    <div id="csFields" style="display:none;">
        <label>Employee ID:</label><br>
        <input type="text" name="employeeId"><br><br>
        <label>Department:</label><br>
        <input type="text" name="department"><br><br>
    </div>

    <div id="dpFields" style="display:none;">
        <label>Vehicle Type:</label><br>
        <input type="text" name="vehicleType"><br><br>
        <label>License Plate:</label><br>
        <input type="text" name="licensePlate"><br><br>
        <label>Available?</label><br>
        <input type="checkbox" name="isAvailable" value="true"> Yes<br><br>
    </div>

    <input type="submit" value="Register">
</form>

<script>
    // Initialize on page load
    window.onload = function() {
        showRoleFields();
    };
</script>
</body>
</html>
