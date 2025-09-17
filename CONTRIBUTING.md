Contributing to ps-cert-tests

Thanks for your interest in contributing! This repo contains simple PowerShell scripts and a small test suite. The guidelines below help keep things consistent and easy to maintain.

Prerequisites
- PowerShell (Windows PowerShell 5.1 or PowerShell 7+)
- Optional: Administrator rights for full testing of certificate store operations
- Pester for running tests (Pester 3.4 or newer works)

Getting started
1) Fork the repository and create a feature branch from main.
2) Make your changes in small, focused commits.
3) Add or update tests where it makes sense.
4) Run the tests locally before opening a pull request.

Running tests
- Install Pester if you don't have it:
  Install-Module Pester -Scope CurrentUser

- From the repository root:
  Invoke-Pester -Path .\Tests

Style and scope
- Keep user-facing scripts compatible with typical enterprise environments.
- Favor clear, defensive error handling and helpful output messages.
- Avoid breaking changes to parameters and behavior unless necessary; if you must, document the change prominently in the README.

Security and safety
- Be careful with operations that modify the LocalMachine certificate store or sensitive registry paths. Prefer non-destructive tests and explicit user prompts.
- Do not introduce hard pinning of SHA-1 fingerprints for security controls. Use thumbprints only for identification in store lookups.

Submitting a pull request (PR)
- Fill in a concise description of what changed and why.
- Reference any related issues.
- Confirm that tests pass locally.

Thank you for contributing!