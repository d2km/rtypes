require RTypes

simple_t_labmda? = RTypes.derive(Simple.t())
simple_t_interpreter? = RTypes.derive!(Simple.t())

complex_t_labmda? = RTypes.derive(Complex, :t, [])
complex_t_interpreter? = RTypes.derive!(Complex, :t, [])

simple_term = Simple.t_value()
complex_term = Complex.t_value()

Benchee.run(%{
  "simple term, closures" => fn -> simple_t_labmda?.(simple_term) end,
  "simple term, interpreter" => fn -> simple_t_interpreter?.(simple_term) end
})

Benchee.run(%{
  "complex term, closures" => fn -> complex_t_labmda?.(complex_term) end,
  "complex term, interpreter" => fn -> complex_t_interpreter?.(complex_term) end
})
