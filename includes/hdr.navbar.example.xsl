<?xml version="1.0" encoding="UTF-8"?>
<Navbar
  data-bs-theme="dark"
  className="navbar-dark bg-dark navbar-expand-lg sticky-top"
  expand="lg"
  sticky="top"
  bg="dark"
  variant="dark"
>
  <Container fluid="xxl" className="px-4">
    <NavbarToggle aria-controls="bdSidebar" aria-label="Toggle docs navigation" className="p-2 me-2">
      <Icon name="list"/>
    </NavbarToggle>
    <NavbarBrand className="d-flex align-items-center fw-semibold" href="/">
      <favicon/>
      <document-title/>
    </NavbarBrand>
    <NavbarToggle aria-controls="navbarContent" aria-label="Toggle navigation"/>
    <NavbarCollapse id="navbarContent">
      <Nav>
        <NavLink href="#">Link One</NavLink>
        <NavLink href="#">Link Two</NavLink>
        <NavLink href="#">Link Three</NavLink>
      </Nav>
      <Nav className="ms-auto align-items-lg-center">
        <Form className="position-relative mx-lg-2 search-box" role="search" data-bs-theme="light">
          <InputGroup>
            <InputGroupText className="bg-primary-subtle">
              <Icon name="search"/>
            </InputGroupText>
            <FormControl placeholder="Search…" aria-label="Search" dir="auto" type="search" value=""/>
          </InputGroup>
        </Form>
        <NavDropdown id="bd-theme" className="nav-item" role="theme-toggle">
          <NavDropdownItem data-bs-theme-value="light">
            <Icon name="brightness-high-fill" className="me-2"/>
            <span>Light</span>
          </NavDropdownItem>
          <NavDropdownItem data-bs-theme-value="dark">
            <Icon name="moon-stars-fill" className="me-2"/>
            <span>Dark</span>
          </NavDropdownItem>
          <NavDropdownItem data-bs-theme-value="auto">
            <Icon name="circle-half" className="me-2"/>
            <span>Auto</span>
          </NavDropdownItem>
        </NavDropdown>
      </Nav>
    </NavbarCollapse>
  </Container>
</Navbar>
