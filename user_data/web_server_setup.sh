#!/bin/bash
yum update -y
yum install -y httpd

systemctl start httpd
systemctl enable httpd

# Custom HTML with dynamic server info
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Web Server - $(hostname)</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }

        .container {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            padding: 40px;
            max-width: 600px;
            width: 100%;
        }

        h1 {
            color: #667eea;
            margin-bottom: 10px;
            font-size: 2.5em;
            text-align: center;
        }

        .subtitle {
            color: #666;
            text-align: center;
            margin-bottom: 30px;
            font-size: 1.1em;
        }

        .info-card {
            background: #f8f9fa;
            border-left: 4px solid #667eea;
            padding: 20px;
            margin: 20px 0;
            border-radius: 8px;
        }

        .info-card h2 {
            color: #333;
            margin-bottom: 15px;
            font-size: 1.3em;
        }

        .info-item {
            display: flex;
            justify-content: space-between;
            padding: 10px 0;
            border-bottom: 1px solid #ddd;
        }

        .info-item:last-child {
            border-bottom: none;
        }

        .label {
            font-weight: 600;
            color: #555;
        }

        .value {
            color: #667eea;
            font-family: 'Courier New', monospace;
            font-weight: 500;
        }

        .about-section {
            background: #fff3cd;
            border-left: 4px solid #ffc107;
            padding: 20px;
            margin: 20px 0;
            border-radius: 8px;
        }

        .about-section h2 {
            color: #856404;
            margin-bottom: 15px;
        }

        .about-section p {
            color: #555;
            line-height: 1.6;
        }

        .footer {
            text-align: center;
            margin-top: 30px;
            color: #999;
            font-size: 0.9em;
        }

        .status-badge {
            display: inline-block;
            background: #28a745;
            color: white;
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 0.9em;
            margin-top: 10px;
        }
    </style>
</head>

<body>
    <div class="container">
        <h1>Emmanuel Kariithi</h1>
        <p class="subtitle">Junior Cloud Engineer | AWS Web Application</p>

        <div class="info-card">
            <h2>📊 Server Information</h2>
            <div class="info-item">
                <span class="label">Hostname:</span>
                <span class="value">$(hostname)</span>
            </div>
            <div class="info-item">
                <span class="label">Private IP:</span>
                <span class="value">$(hostname -I | awk '{print $1}')</span>
            </div>
            <div class="info-item">
                <span class="label">Operating System:</span>
                <span class="value">$(cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2 | tr -d '"')</span>
            </div>
            <div class="info-item">
                <span class="label">Architecture:</span>
                <span class="value">$(uname -m)</span>
            </div>
            <span class="status-badge">✓ Server Online</span>
        </div>

        <div class="about-section">
            <h2>👨‍💻 About Me</h2>
            <p>
                Hello! I'm a passionate Junior Cloud Engineer specializing in AWS infrastructure
                and automation. This project demonstrates my skills in:
            </p>
            <ul style="margin-top: 10px; margin-left: 20px; color: #555;">
                <li>AWS EC2, VPC, and Load Balancing</li>
                <li>Infrastructure automation with Terraform</li>
                <li>Linux system administration</li>
                <li>Secure cloud architecture design</li>
                <li>DevOps best practices</li>
            </ul>
            <p style="margin-top: 15px;">
                I love building scalable, secure, and automated cloud solutions.
                Always learning, always building!
            </p>
        </div>

        <div class="footer">
            <p>Deployed via Terraform | Load Balanced with AWS ALB</p>
            <p>$(date "+%Y-%m-%d %H:%M:%S")</p>
        </div>
    </div>
</body>

</html>
EOF