# Pull Request Template

## Description

Briefly describe the changes made in this pull request. What issue does this PR address?

## Type of Change

Please select the type of change that best describes your PR:

- [ ] **Bug fix** - Fixes a reported bug
- [ ] **New feature** - Adds new functionality
- [ ] **Breaking change** - Changes existing behavior in a backward-incompatible way
- [ ] **Documentation** - Improves documentation
- [ ] **Refactoring** - Code restructuring without behavior changes
- [ ] **Performance** - Performance improvements
- [ ] **Tests** - Adding or updating tests
- [ ] **Other** - Please describe below

## Related Issues

Fixes #<issue_number>
Related to #<issue_number>
Closes #<issue_number>

## Motivation and Context

Why is this change necessary? What problem does it solve?

Provide context about:

- The use case this addresses
- Why the current implementation is insufficient
- The impact of this change on users

## Changes Made

Detailed list of changes:

- **File 1**: Description of changes
- **File 2**: Description of changes
- **File 3**: Description of changes

### Key Features/Improvements

- Feature/improvement 1
- Feature/improvement 2
- Feature/improvement 3

## How This Has Been Tested

Describe the testing performed to validate these changes:

- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] Manual testing performed
- [ ] All existing tests pass

### Test Results

```
Paste test output or describe test coverage here
```

### Testing Instructions

If manual testing is required, provide steps for reviewers:

1. Step one
2. Step two
3. Step three

## Screenshots (if applicable)

If your changes affect the user interface or include visual elements, add screenshots:

**Before:**
![Before](screenshot-before.png)

**After:**
![After](screenshot-after.png)

## Checklist

Please confirm the following:

### Code Quality

- [ ] My code follows the project's code style guidelines
- [ ] I have performed a self-review of my code
- [ ] I have formatted my code using `black` and `isort`
- [ ] I have added type hints where appropriate
- [ ] I have included docstrings for new functions/classes

### Testing

- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing tests pass locally with my changes
- [ ] I have tested on all target platforms (Windows, macOS, Linux)

### Documentation

- [ ] I have updated the documentation accordingly
- [ ] I have added examples where appropriate
- [ ] I have updated the CHANGELOG.md
- [ ] All new public APIs have documentation

### Breaking Changes

If this PR contains breaking changes:

- [ ] I have documented the breaking changes
- [ ] I have provided migration instructions
- [ ] I have updated the version number appropriately

## Performance Impact

Does this change affect performance?

- [ ] No performance impact
- [ ] Improves performance
- [ ] May impact performance (please explain below)

If there are performance implications, describe them:

```
# Describe performance impact here
```

## Backward Compatibility

- [ ] This change is backward compatible
- [ ] This change breaks backward compatibility

If not backward compatible, describe migration path:

```
# Migration instructions here
```

## Dependencies

- [ ] No new dependencies added
- [ ] New dependencies added:

  - **Dependency 1**: version - reason for adding
  - **Dependency 2**: version - reason for adding

## Additional Notes

Any additional information that reviewers should know:

- Alternative approaches considered
- Future improvements planned
- Known limitations
- Areas that could use further review

## Reviewer Notes

Specific areas where you'd like reviewer focus:

- Complexity in specific functions
- Algorithm choices
- API design decisions
- Security considerations

---

## Review Checklist for Maintainers

When reviewing this PR, please verify:

- [ ] Code follows project style guidelines
- [ ] Changes are well-documented
- [ ] Tests are adequate and passing
- [ ] No breaking changes (or properly documented)
- [ ] Performance impact is acceptable
- [ ] Security implications are considered
- [ ] Documentation is updated
- [ ] CHANGELOG is updated
- [ ] All CI checks pass

---

**Thank you for contributing to NIP!** 🚀

Your contribution helps make NIP better for everyone. We appreciate your time and effort!
