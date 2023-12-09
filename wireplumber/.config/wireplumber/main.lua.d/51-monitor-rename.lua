rule = {
  matches = {
    {
      { "node.name", "equals", "alsa_output.pci-0000_0a_00.1.hdmi-stereo" },
    },
  },
  apply_properties = {
    ["node.nick"] = "My Juicy Jacky Monitor",
  },
}

table.insert(alsa_monitor.rules, rule)
