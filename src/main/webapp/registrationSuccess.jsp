<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Registration Success</title>
  <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100 flex items-center justify-center min-h-screen">
<div class="bg-white p-8 rounded-lg shadow-lg text-center">
  <h2 class="text-2xl font-bold mb-4">Registration Successful!</h2>
  <p>Your User ID: <%= request.getParameter("userId") %></p>
  <a href="login.jsp" class="mt-4 inline-block bg-blue-600 text-white p-2 rounded-md hover:bg-blue-700">Go to Login</a>
</div>
</body>
</html>