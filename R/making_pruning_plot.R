adj = mse_data[1,2]
len = length(cp_table[,"nsplit"])

data_conc = data.frame(
  rep(cp_table[, "nsplit"],3),
  c(cp_table[, "xerror"]*adj,
    cp_table[, "rel error"]*adj,
    c(mse_values[2,])
  ),
  c(rep("Cross validation Error",len),
    rep("Training Error",len),
    rep("Test Error",len)
  )
)

ggplot(data_conc, aes(x = data_conc[,1], y = data_conc[,2], color = data_conc[,3])) +
  geom_line() +
  geom_point() +
  scale_color_manual(values = c("orange", "red","blue")) +
  labs(
    x = "Number of Splits", y = "Mean Squared Error",
    title = "MSE vs Tree Complexity",
    color = "MSE Type"
  ) +
  theme_minimal()